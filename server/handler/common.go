package handler

import (
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/rs/zerolog/log"
)

func respondJSON(w http.ResponseWriter, status int, payload interface{}) {

	//TODO String comparison is not very elegant!
	if CompareSensitive(fmt.Sprint(payload), "[]") {
		payload = []interface{}{}
	}

	resultMap := map[string]interface{}{"data": payload}
	response, err := json.Marshal(resultMap)
	if err != nil {
		log.Error().Err(err).Msg("failed to marshal payload")
		w.WriteHeader(http.StatusInternalServerError)
		_, err = w.Write([]byte(err.Error()))
		if err != nil {
			log.Error().Err(err).Msg("failed to write response")
		}
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_, err = w.Write(response)
	if err != nil {
		log.Error().Err(err).Msg("failed to write response")
	}
}

func respondError(w http.ResponseWriter, code int, message string) {
	resultMap := map[string]interface{}{"error": message}
	response, err := json.Marshal(resultMap)
	if err != nil {
		log.Error().Err(err).Msg("failed to marshal payload")
		w.WriteHeader(http.StatusInternalServerError)
		_, err = w.Write([]byte(err.Error()))
		if err != nil {
			log.Error().Err(err).Msg("failed to write response")
		}
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	_, err = w.Write(response)
	if err != nil {
		log.Error().Err(err).Msg("failed to write response")
	}
}

func respondString(w http.ResponseWriter, code int, message string) {

	response := []byte(message)
	w.Header().Set("Content-Type", "text/plain")
	w.WriteHeader(code)
	_, err := w.Write(response)
	if err != nil {
		log.Error().Err(err).Msg("failed to write response")
	}
}

//
func respondCode(w http.ResponseWriter, code int) {

	w.Header().Set("Content-Type", "text/plain")
	w.WriteHeader(code)
}

// taken from https://www.digitalocean.com/community/questions/how-to-efficiently-compare-strings-in-go
func CompareSensitive(a, b string) bool {
	// a quick optimization. If the two strings have a different
	// length then they certainly are not the same
	if len(a) != len(b) {
		return false
	}

	for i := 0; i < len(a); i++ {
		// if the characters already match then we don't need to
		// alter their case. We can continue to the next rune
		if a[i] == b[i] {
			continue
		}
		if a[i] != b[i] {
			// the lowercase characters do not match so these
			// are considered a mismatch, break and return false
			return false
		}
	}
	// The string length has been traversed without a mismatch
	// therefore the two match
	return true
}
