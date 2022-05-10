package handler

import (
	"github.com/Festivals-App/festivals-database/server/config"
	"github.com/Festivals-App/festivals-database/server/status"
	"net/http"
)

func GetVersion(conf *config.Config, w http.ResponseWriter, r *http.Request) {

	respondString(w, http.StatusOK, status.VersionString())
}

func GetInfo(conf *config.Config, w http.ResponseWriter, r *http.Request) {

	respondJSON(w, http.StatusOK, status.InfoString())
}

func GetHealth(conf *config.Config, w http.ResponseWriter, r *http.Request) {

	respondCode(w, status.HealthStatus())
}
