package config

import (
	"github.com/pelletier/go-toml"
	"github.com/rs/zerolog/log"

	servertools "github.com/Festivals-App/festivals-server-tools"
)

type Config struct {
	ServiceBindHost     string
	ServicePort         int
	ServiceKey          string
	TLSRootCert         string
	TLSCert             string
	TLSKey              string
	DatabaseBindAddress string
	DatabasePort        int
	LoversEar           string
	Interval            int
	IdentityEndpoint    string
	InfoLog             string
	TraceLog            string
}

func ParseConfig(cfgFile string) *Config {

	content, err := toml.LoadFile(cfgFile)
	if err != nil {
		log.Fatal().Err(err).Msg("server initialize: could not read config file at '" + cfgFile + "' with error: " + err.Error())
	}

	serviceBindHost := content.Get("service.bind-host").(string)
	serverPort := content.Get("service.port").(int64)
	serviceKey := content.Get("service.key").(string)

	tlsrootcert := content.Get("tls.festivaslapp-root-ca").(string)
	tlscert := content.Get("tls.cert").(string)
	tlskey := content.Get("tls.key").(string)

	databaseBindAdress := content.Get("database.bind-address").(string)
	databasePort := content.Get("database.port").(int64)

	loversear := content.Get("heartbeat.endpoint").(string)
	interval := content.Get("heartbeat.interval").(int64)

	identity := content.Get("authentication.endpoint").(string)

	infoLogPath := content.Get("log.info").(string)
	traceLogPath := content.Get("log.trace").(string)

	tlsrootcert = servertools.ExpandTilde(tlsrootcert)
	tlscert = servertools.ExpandTilde(tlscert)
	tlskey = servertools.ExpandTilde(tlskey)
	infoLogPath = servertools.ExpandTilde(infoLogPath)
	traceLogPath = servertools.ExpandTilde(traceLogPath)

	return &Config{
		ServiceBindHost:     serviceBindHost,
		ServicePort:         int(serverPort),
		ServiceKey:          serviceKey,
		TLSRootCert:         tlsrootcert,
		TLSCert:             tlscert,
		TLSKey:              tlskey,
		DatabaseBindAddress: databaseBindAdress,
		DatabasePort:        int(databasePort),
		LoversEar:           loversear,
		Interval:            int(interval),
		IdentityEndpoint:    identity,
		InfoLog:             infoLogPath,
		TraceLog:            traceLogPath,
	}
}
