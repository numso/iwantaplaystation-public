# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# https://developers.google.com/identity/protocols/oauth2
config :checker, Checker.GmailAuth,
  client_id: "",
  client_secret: "",
  refresh_token: ""

config :checker, Checker.Mailer, adapter: Swoosh.Adapters.Gmail

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
