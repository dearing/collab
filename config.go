package main

import (
	"encoding/json"
	"io/ioutil"
	"log"
)

type Config struct {
	Certificate    string
	CertificateKey string
	WWWHost        string
	WWWRoot        string
	Tag            string
	TLS            bool
	Verbose        bool
	EnableWWW      bool
}

// Load up a JSON config file.
func (c *Config) LoadConfig(path string) {

	f, err := ioutil.ReadFile(path)
	if err != nil {
		log.Panicln(err)
	}

	if err := json.Unmarshal(f, &c); err != nil {
		log.Panicln(err)
	}

}

// Generate a default config in the current directory for the user to manipulate.
func (c *Config) GenerateConfig(path string) {

	c = &Config{
		Certificate:    "cert.pem",
		CertificateKey: "cert.key",
		WWWHost:        ":9001",
		WWWRoot:        "www",
		Tag:            "/chat",
		TLS:            false,
		Verbose:        true,
		EnableWWW:      false,
	}

	b, _ := json.MarshalIndent(c, "", "\t")
	ioutil.WriteFile(*conf, b, 0644)

}
