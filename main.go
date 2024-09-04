package main

import (
    "encoding/json"
    "net/http"
    "time"
)

type TimeResponse struct {
    CurrentTime string `json:"current_time"`
}

func timeHandler(w http.ResponseWriter, r *http.Request) {
    loc, err := time.LoadLocation("Africa/Lagos")
    if err != nil {
        loc = time.UTC
    }
    
    currentTime := time.Now().In(loc).Format(time.RFC3339)
    response := TimeResponse{CurrentTime: currentTime}
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(response)
}

func main() {
    http.HandleFunc("/time", timeHandler)
    http.ListenAndServe(":8080", nil)
}
