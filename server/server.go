package server

import (
	"crypto/tls"
	"net/http"
	"strconv"
	"time"

	"github.com/Festivals-App/festivals-database/server/config"
	"github.com/Festivals-App/festivals-database/server/handler"
	token "github.com/Festivals-App/festivals-identity-server/jwt"
	festivalspki "github.com/Festivals-App/festivals-pki"
	servertools "github.com/Festivals-App/festivals-server-tools"
	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/rs/zerolog/log"
)

// Server has router and db instances
type Server struct {
	Router    *chi.Mux
	Config    *config.Config
	TLSConfig *tls.Config
	Validator *token.ValidationService
}

func NewServer(config *config.Config) *Server {
	server := &Server{}
	server.initialize(config)
	return server
}

// Initialize the server with predefined configuration
func (s *Server) initialize(config *config.Config) {

	s.Router = chi.NewRouter()
	s.Config = config

	s.setIdentityService()
	s.setTLSHandling()
	s.setMiddleware()
	s.setRoutes()
}

func (s *Server) setIdentityService() {

	config := s.Config

	val := token.NewValidationService(config.IdentityEndpoint, config.TLSCert, config.TLSKey, config.TLSRootCert, config.ServiceKey, false)
	if val == nil {
		log.Fatal().Msg("Failed to create validator.")
	}
	s.Validator = val
}

func (s *Server) setTLSHandling() {

	tlsConfig, err := festivalspki.NewServerTLSConfig(s.Config.TLSCert, s.Config.TLSKey, s.Config.TLSRootCert)
	if err != nil {
		log.Fatal().Err(err).Msg("failed to set TLS handling")
	}
	s.TLSConfig = tlsConfig
}

func (s *Server) setMiddleware() {
	// tell the ruter which middleware to use
	s.Router.Use(
		// used to log the request to the console | development
		servertools.Middleware(servertools.TraceLogger(s.Config.TraceLog)),
		// tries to recover after panics
		middleware.Recoverer,
	)
}

// setRouters sets the all required routers
func (s *Server) setRoutes() {

	s.Router.Get("/version", s.handleRequest(handler.GetVersion))
	s.Router.Get("/info", s.handleRequest(handler.GetInfo))
	s.Router.Get("/health", s.handleRequest(handler.GetHealth))

	s.Router.Post("/update", s.handleRequest(handler.MakeUpdate))
	s.Router.Get("/log", s.handleRequest(handler.GetLog))
	s.Router.Get("/log/trace", s.handleRequest(handler.GetTraceLog))
}

func (s *Server) Run(conf *config.Config) {

	server := http.Server{
		ReadTimeout:       10 * time.Second,
		WriteTimeout:      25 * time.Second,
		IdleTimeout:       60 * time.Second,
		ReadHeaderTimeout: 5 * time.Second,
		Addr:              conf.ServiceBindHost + ":" + strconv.Itoa(conf.ServicePort),
		Handler:           s.Router,
		TLSConfig:         s.TLSConfig,
	}

	if err := server.ListenAndServeTLS("", ""); err != nil {
		log.Fatal().Err(err).Str("type", "server").Msg("Failed to run server")
	}
}

type JWTAuthenticatedHandlerFunction func(claims *token.UserClaims, w http.ResponseWriter, r *http.Request)

func (s *Server) handleRequest(requestHandler JWTAuthenticatedHandlerFunction) http.HandlerFunc {

	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {

		claims := token.GetValidClaims(r, s.Validator)
		if claims == nil {
			servertools.UnauthorizedResponse(w)
			return
		}
		requestHandler(claims, w, r)
	})
}
