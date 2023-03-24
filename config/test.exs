import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :chat, ChatWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "sDhFzufI5czvnV9pKK27C2HHG+IWAJl/4pp+V6A8zbEyq3UACyNcRZ4ikBt2//EZ",
  server: false

config :chat, Chat.Repo,
  username: "postgres",
  password: "postgres",
  database: "chat_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# In test we don't send emails.
# config :chat, Chat.Mailer,
#  adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
