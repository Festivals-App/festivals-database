package main

import (
	"time"

	"github.com/Festivals-App/festivals-database/server"
	"github.com/Festivals-App/festivals-database/server/config"
	servertools "github.com/Festivals-App/festivals-server-tools"
	"github.com/rs/zerolog/log"
)

func main() {

	servertools.InitializeGlobalLogger("/var/log/festivals-database-node/info.log", true)
	log.Info().Msg("Server startup.")

	conf := config.DefaultConfig()
	log.Info().Msg("Server configuration was initialized.")

	server := server.NewServer(conf)
	go server.Run(conf)
	log.Info().Msg("Server did start.")

	go sendNodeHeartbeat(conf)
	go sendDatabaseHeartbeat(conf)
	log.Info().Msg("Heartbeat routines where started.")

	// wait forever
	// https://stackoverflow.com/questions/36419054/go-projects-main-goroutine-sleep-forever
	select {}
}

func sendNodeHeartbeat(conf *config.Config) {

	heartbeatClient, err := servertools.HeartbeatClient(conf.TLSCert, conf.TLSKey)
	if err != nil {
		log.Fatal().Err(err).Str("type", "server").Msg("Failed to create heartbeat client")
	}
	beat := &servertools.Heartbeat{
		Service:   "festivals-database-node",
		Host:      "https://" + conf.ServiceBindHost,
		Port:      conf.ServicePort,
		Available: true,
	}

	t := time.NewTicker(time.Duration(conf.Interval) * time.Second)
	defer t.Stop()
	for range t.C {
		err = servertools.SendHeartbeat(heartbeatClient, conf.LoversEar, conf.ServiceKey, beat)
		if err != nil {
			log.Error().Err(err).Msg("Failed to send heartbeat")
		}
	}
}

func sendDatabaseHeartbeat(conf *config.Config) {

	heartbeatClient, err := servertools.HeartbeatClient(conf.TLSCert, conf.TLSKey)
	if err != nil {
		log.Fatal().Err(err).Str("type", "server").Msg("Failed to create heartbeat client")
	}
	beat := &servertools.Heartbeat{
		Service:   "festivals-database",
		Host:      "mysql://" + conf.DatabaseBindAddress,
		Port:      conf.DatabasePort,
		Available: true,
	}

	t := time.NewTicker(time.Duration(conf.Interval) * time.Second)
	defer t.Stop()
	for range t.C {
		err = servertools.SendHeartbeat(heartbeatClient, conf.LoversEar, conf.ServiceKey, beat)
		if err != nil {
			log.Error().Err(err).Msg("Failed to send heartbeat")
		}
	}
}
