// Cop Alert Server
// Copyright (C) 2013 Alex Reidy

// copdata.go - Contains functions for retrieving and manipulating cop data
// Note: Line number = CopID, starting at 1.

package main

import (
    "fmt"
    "bufio"
    "os"
    "strings"
    "strconv"
    "math"
    "time"
)

const (
    CopFilePath = "cop-data.txt"
    CopLifespanInSeconds = 10800
    MaxUpdateRadius = 0.165
)

func applyToEachLineIn(path string, use Lambda) {
    file, err := os.Open(path)
    if err != nil {
        log("ERROR")
    }

    scanner := bufio.NewScanner(file)
    if err != nil {
        log("ERROR")
    }

    for scanner.Scan() {
        line := scanner.Text()
        if (!use(line)) {
            break
        }
    }
}

func toCop(copData string) Cop {
    components := strings.Split(copData, ",")
    coordinate, success := convStrToCoordinate(components[0] + "," + components[1])
    timeAdded, err2 := strconv.ParseInt(components[len(components) - 1], 0, 64)
    if success && err2 != nil {
        return Cop{coordinate, timeAdded}
    }
    return *new(Cop)
}

func getCopWithID(id int) Cop {
    var copData string
    i := 0
    fn := func(line string) bool {
        if i == id {
            copData = line
            return true // done
        }
        i++
        return false // continue
    }

    applyToEachLineIn(CopFilePath, fn)
    
    if copData != "" {
        return toCop(copData)
    }
    return *new(Cop)
}

func removeCopWithID(id int) {
    i := 0
    fn := func(line string) bool {
        if i == id {
            copfile, err := os.Open(CopFilePath)
            if err != nil {
                return true
            }
            tempfile, err := os.Create("temp.txt")
            if err != nil {
                return true
            }

            scanner := bufio.NewScanner(copfile)

            j := 0
            for scanner.Scan() {
                if j != i {
                    tempfile.WriteString(scanner.Text() + "\n")
                }
            }
            return true
        }

        i++
        return false
    }

    applyToEachLineIn(CopFilePath, fn)

}

func storeCopInfo(cop Cop) {
    file, err := os.OpenFile(CopFilePath, os.O_APPEND | os.O_WRONLY, 0666)
    if err != nil { // File probably doesn't exist, so create it
        file, err = os.Create(CopFilePath)
        if err != nil {
            log("ERROR CREATING FILE")
            return
        }
    }

    info := fmt.Sprintf("%f", cop.position.latitude) + fmt.Sprintf(",%f", cop.position.longitude) + fmt.Sprintf(",%d\n", cop.timeAdded)
    file.WriteString(info)
    file.Close()

    log("COP INFO ADDED")
}

func pruneOutdatedCopLocations() {
    if len(connections) == 0 {
        return
    }

    file, err := os.Open(CopFilePath)
    if err != nil {
        log("ERROR OPENING FILE")
        return
    }

    newfile, err := os.Create("temp.txt")
    if err != nil {
        log("ERROR CREATING FILE")
        return
    }

    scanner := bufio.NewScanner(file)
    numCopsPruned := 0

    for scanner.Scan() {
        components := strings.Split(scanner.Text(), ",")
        timeAdded, _ := strconv.ParseInt(components[len(components) - 1], 0, 64)

        if time.Now().Unix() - timeAdded > CopLifespanInSeconds {
            numCopsPruned++
            // Simply don't write this cop to the new file
            continue
        }

        newfile.WriteString(scanner.Text() + "\n")
    }

    os.Rename("temp.txt", CopFilePath) // (overwrites original)

    log(fmt.Sprintf("PRUNED %d OUTDATED COPS", numCopsPruned))
}

func getCopsCloseTo(pos Coordinate) string {
    file, err := os.Open(CopFilePath)
    if err != nil {
        log("ERROR OPENING FILE")
        return ""
    }

    data := ""
    scanner := bufio.NewScanner(file)
    lines := 0.0
    nearby := 0.0
    for scanner.Scan() {
        line := scanner.Text()
        component := strings.Split(line, ",")
        copPos, ok := convStrToCoordinate(component[0] + "," + component[1])
        if !ok {
            continue
        }

        distanceFromCop := math.Sqrt(math.Pow(copPos.latitude - pos.latitude, 2) + math.Pow(copPos.longitude - pos.longitude, 2))

        if distanceFromCop <= MaxUpdateRadius {
            data += line + "\n"
            nearby++
        }

        lines++
    }

    if nearby != 0 {
        fmt.Printf("Cops nearby: %d / %d\n", int(nearby), int(lines))
    }

    return data
}