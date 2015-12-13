// Cop Alert Server
// Copyright (C) 2013 Alex Reidy

package main

import (
    "fmt"
    "net"
    "bufio"
    //"io/ioutil"
    //"io"
    "strings"
    "strconv"
    "time"
)

var connections []net.Conn

type Coordinate struct {
    latitude, longitude float64
}

type Cop struct {
    position Coordinate
    timeAdded int64
}

func broadcast(message string) {
    for i := 0; i < len(connections); i++ {
        connections[i].Write([]byte(message))
    }
}

func convStrToCoordinate(str string) (Coordinate, bool) {
    if strings.Contains(str, ",") && strings.Count(str, ",") == 1 {
        goto start
    }
failureHandler:
    log("UNABLE TO CONVERT STRING")
    return *new(Coordinate), false

start:
    component := strings.Split(str, ",")
    latitude, err1  := strconv.ParseFloat(component[0], 64)
    longitude, err2 := strconv.ParseFloat(component[1], 64)
    if err1 != nil || err2 != nil {
        goto failureHandler
    }

    return Coordinate{latitude, longitude}, true

}

// todo: time out and release connections
func manage(client net.Conn, clientIndex int) {
    reader := bufio.NewReader(client)

    numCopsAdded := 0
    numMessagesFromClient := 0

    for {
        message, err := reader.ReadString('\n')
        if err != nil {
            log("CLIENT DISCONNECTED")
            client.Close()
            connections = connections[:clientIndex]
            break
        }

        stripNewline(&message)
        component := strings.Split(message, ",")
        log("GOT MESSAGE: " + message)

        position := component[1] + "," + component[2]
        pos, ok := convStrToCoordinate(position)
        if !ok {
            continue
        }

        toAddCop, err := strconv.ParseInt(string(component[3][0]), 0, 32)
        if err != nil {
            fmt.Println(err)
            continue
        }

        if toAddCop == 1 && numCopsAdded < 10 {
            storeCopInfo(Cop{pos, time.Now().Unix()})
            numCopsAdded++
        }

        switch component[0] {
        case "CHECK_FOR_NEARBY_COPS":
            if len(getCopsCloseTo(pos)) > 0 {
                client.Write([]byte("YES"))
            } else {
                client.Write([]byte("NO"))
            }

        case "UPDATE":
            client.Write([]byte(getCopsCloseTo(pos)))
        }

    }
}

func main() {
    connections = make([]net.Conn, 0)
    listener, err := net.Listen("tcp", ":5010")
    if err != nil {
        log("ERROR INITIALIZING LISTENER")
        return
    }

    go func() {
        for {
            log(fmt.Sprintf("# connections: %d", len(connections)))
            time.Sleep(10 * time.Second)
        }
    }()

    go func() {
        for {
            pruneOutdatedCopLocations()
            time.Sleep(time.Minute)
        }
    }()

    for {
        conn, err := listener.Accept()
        if err != nil {
            log("ERROR ACCEPTING CONNECTION")
            continue
        }

        log("CONNECTION RECEIVED")
        connections = append(connections, conn)
        go manage(conn, len(connections) - 1)
    }

}