package handler

import (
	"net/http"

	"github.com/Festivals-App/festivals-database/server/status"
	token "github.com/Festivals-App/festivals-identity-server/jwt"
	servertools "github.com/Festivals-App/festivals-server-tools"
	"github.com/rs/zerolog/log"
)

func GetVersion(claims *token.UserClaims, w http.ResponseWriter, r *http.Request) {

	if claims.UserRole != token.ADMIN {
		log.Error().Msg("User is not authorized to get service version.")
		servertools.UnauthorizedResponse(w)
		return
	}

	servertools.RespondString(w, http.StatusOK, status.VersionString())
}

func GetInfo(claims *token.UserClaims, w http.ResponseWriter, r *http.Request) {

	if claims.UserRole != token.ADMIN {
		log.Error().Msg("User is not authorized to get service info.")
		servertools.UnauthorizedResponse(w)
		return
	}

	servertools.RespondJSON(w, http.StatusOK, status.InfoString())
}

func GetHealth(claims *token.UserClaims, w http.ResponseWriter, r *http.Request) {

	if claims.UserRole != token.ADMIN {
		log.Error().Msg("User is not authorized to get service health.")
		servertools.UnauthorizedResponse(w)
		return
	}

	servertools.RespondCode(w, status.HealthStatus())
}
