package handler

import (
	"net/http"

	"github.com/Festivals-App/festivals-database/server/status"
	token "github.com/Festivals-App/festivals-identity-server/jwt"
	servertools "github.com/Festivals-App/festivals-server-tools"
	"github.com/rs/zerolog/log"
)

func MakeUpdate(claims *token.UserClaims, w http.ResponseWriter, _ *http.Request) {

	if claims.UserRole != token.ADMIN {
		log.Error().Msg("User is not authorized to update service.")
		servertools.UnauthorizedResponse(w)
		return
	}
	newVersion, err := servertools.RunUpdate(status.ServerVersion, "Festivals-App", "festivals-database", "/usr/local/festivals-database-node/update.sh")
	if err != nil {
		log.Error().Err(err).Msg("Failed to update")
		servertools.RespondError(w, http.StatusInternalServerError, "Failed to update")
		return
	}

	servertools.RespondString(w, http.StatusAccepted, newVersion)
}
