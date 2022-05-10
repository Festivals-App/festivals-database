package config

import (
	"os"

	"github.com/pelletier/go-toml"
	"github.com/rs/zerolog/log"
)

type Config struct {
	ServiceBindAddress string
	ServicePort        int
	ServiceKey         string
	LoversEar          string
	AdminKeys          []string
}

func DefaultConfig() *Config {

	// first we try to parse the config at the global configuration path
	if fileExists("/etc/festivals-database-node.conf") {
		config := ParseConfig("/etc/festivals-database-node.conf")
		if config != nil {
			return config
		}
	}

	// if there is no global configuration check the current folder for the template config file
	// this is mostly so the application will run in development environment
	path, err := os.Getwd()
	if err != nil {
		log.Fatal().Msg("server initialize: could not read default config file with error:" + err.Error())
	}
	path = path + "/config_template.toml"
	return ParseConfig(path)
}

func ParseConfig(cfgFile string) *Config {

	content, err := toml.LoadFile(cfgFile)
	if err != nil {
		log.Fatal().Msg("server initialize: could not read config file at '" + cfgFile + "' with error: " + err.Error())
	}

	serverBindAdress := content.Get("service.bind-address").(string)
	serverPort := content.Get("service.port").(int64)
	serviceKey := content.Get("service.key").(string)

	loversear := content.Get("heartbeat.endpoint").(string)

	adminKeyValues := content.Get("authentication.admin-keys").([]interface{})
	adminKeys := make([]string, len(adminKeyValues))
	for i, v := range adminKeyValues {
		adminKeys[i] = v.(string)
	}

	return &Config{
		ServiceBindAddress: serverBindAdress,
		ServicePort:        int(serverPort),
		ServiceKey:         serviceKey,
		LoversEar:          loversear,
		AdminKeys:          adminKeys,
	}
}

// fileExists checks if a file exists and is not a directory before we
// try using it to prevent further errors.
// see: https://golangcode.com/check-if-a-file-exists/
func fileExists(filename string) bool {
	info, err := os.Stat(filename)
	if os.IsNotExist(err) {
		return false
	}
	return !info.IsDir()
}
