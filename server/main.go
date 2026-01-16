package main

import (
	"encoding/json"
	"log"
	"net/http"
	"strconv"
	"strings"
	"time"
)

//
// Models
//

type User struct {
	ID    string `json:"id"`
	Email string `json:"email"`
	Name  string `json:"name"`
}

type Event struct {
	ID          string    `json:"id"`
	Title       string    `json:"title"`
	Description string    `json:"description"`
	Timestamp   time.Time `json:"timestamp"`
	HasDownload bool      `json:"hasDownload"`
}

type EventDetails struct {
	Event
	Metadata map[string]string `json:"metadata"`
}

//
// In-memory data
//

var testUser = User{
	ID:    "1",
	Email: "test@demo.com",
	Name:  "Test User",
}

var events []Event

func init() {
	now := time.Now()
	for i := 1; i <= 100; i++ {
		events = append(events, Event{
			ID:          "evt_" + strconv.Itoa(i),
			Title:       "Event #" + strconv.Itoa(i),
			Description: "This is event number " + strconv.Itoa(i),
			Timestamp:   now.Add(-time.Duration(i) * time.Hour),
			HasDownload: i%5 == 0, // every 5th event has a download
		})
	}
}

//
// Helpers
//

func writeJSON(w http.ResponseWriter, status int, v interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}

//
// Auth middleware (intentionally simple)
//

func auth(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Header.Get("Authorization") != "Bearer dummy-token" {
			http.Error(w, "unauthorized", http.StatusUnauthorized)
			return
		}
		next.ServeHTTP(w, r)
	})
}

//
// Handlers
//

func loginHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var body struct {
		Email    string `json:"email"`
		Password string `json:"password"`
	}

	if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
		http.Error(w, "invalid json", http.StatusBadRequest)
		return
	}

	// Hardcoded credentials
	if body.Email != testUser.Email || body.Password != "password" {
		http.Error(w, "invalid credentials", http.StatusUnauthorized)
		return
	}

	writeJSON(w, http.StatusOK, map[string]interface{}{
		"token": "dummy-token",
		"user":  testUser,
	})
}

func meHandler(w http.ResponseWriter, r *http.Request) {
	writeJSON(w, http.StatusOK, testUser)
}

func eventsHandler(w http.ResponseWriter, r *http.Request) {
	page, _ := strconv.Atoi(r.URL.Query().Get("page"))
	limit, _ := strconv.Atoi(r.URL.Query().Get("limit"))

	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 50 {
		limit = 20
	}

	start := (page - 1) * limit
	end := start + limit

	if start > len(events) {
		start = len(events)
	}
	if end > len(events) {
		end = len(events)
	}

	writeJSON(w, http.StatusOK, map[string]interface{}{
		"page":   page,
		"limit":  limit,
		"total":  len(events),
		"events": events[start:end],
	})
}

func eventDetailsHandler(w http.ResponseWriter, r *http.Request) {
	path := strings.TrimPrefix(r.URL.Path, "/events/")
	parts := strings.Split(path, "/")

	id := parts[0]

	// Download endpoint
	if len(parts) == 2 && parts[1] == "download" {
		streamLargeFile(w)
		return
	}

	for _, e := range events {
		if e.ID == id {
			details := EventDetails{
				Event: e,
				Metadata: map[string]string{
					"deviceId": "sensor-42",
					"severity": "high",
					"region":   "eu-central",
				},
			}
			writeJSON(w, http.StatusOK, details)
			return
		}
	}

	http.Error(w, "event not found", http.StatusNotFound)
}

//
// Large file streaming (≈1GB, generated on the fly)
//

func streamLargeFile(w http.ResponseWriter) {
	w.Header().Set("Content-Type", "text/plain")
	w.Header().Set("Content-Disposition", "attachment; filename=log.txt")

	flusher, ok := w.(http.Flusher)
	if !ok {
		http.Error(w, "streaming not supported", http.StatusInternalServerError)
		return
	}

	chunk := make([]byte, 1024*1024) // 1MB
	for i := range chunk {
		chunk[i] = 'A'
	}

	for i := 0; i < 1024; i++ { // ~1GB total
		_, err := w.Write(chunk)
		if err != nil {
			return
		}
		flusher.Flush()
	}
}

//
// Main
//

func main() {
	mux := http.NewServeMux()

	mux.HandleFunc("/login", loginHandler)
	mux.Handle("/me", auth(http.HandlerFunc(meHandler)))
	mux.Handle("/events", auth(http.HandlerFunc(eventsHandler)))
	mux.Handle("/events/", auth(http.HandlerFunc(eventDetailsHandler)))

	log.Println("Backend running on http://localhost:8080")
	log.Fatal(http.ListenAndServe(":8080", mux))
}
