# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :ex_jenkins,
  host: "localhost",
  protocol: "http", # http or https.  Default is http
  port: "8080",
  username: "admin",
  password: "password",
  token: "password"
