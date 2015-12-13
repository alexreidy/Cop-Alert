// Cop Alert Server
// Copyright (C) 2013 Alex Reidy

package main

import (
    "fmt"
)

var loggingIsEnabled = true

type Lambda func(string) bool

func log(message string) {
    if loggingIsEnabled {
        fmt.Println(message)
    }
}

func stripNewline(str *string) {
    derefstr := *str
    if len(derefstr) > 0 {
        *str = derefstr[:len(derefstr) - 1]
    }
}