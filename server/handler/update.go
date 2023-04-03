package handler

import (
	"net/http"

	"github.com/Festivals-App/festivals-database/server/config"
	"github.com/Festivals-App/festivals-database/server/status"
	"github.com/Festivals-App/festivals-gateway/server/update"
	"github.com/rs/zerolog/log"
)

func MakeUpdate(conf *config.Config, w http.ResponseWriter, _ *http.Request) {

	newVersion, err := update.RunUpdate(status.ServerVersion, "Festivals-App", "festivals-database", "/usr/local/festivals-database-node/update.sh")
	if err != nil {
		log.Error().Err(err).Msg("Failed to update")
		respondError(w, http.StatusInternalServerError, "Failed to update")
		return
	}

	respondString(w, http.StatusAccepted, newVersion)
}