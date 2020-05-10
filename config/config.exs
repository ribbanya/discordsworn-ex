import Config

config :ex_dice_roller,
  cache_table: ExDiceRoller.Cache

config :nostrum,
  # The token of your bot as a string
  token: System.get_env("DISCORDSWORN_TOKEN"),
  # The number of shards you want to run your bot under, or :auto.
  num_shards: :auto

config :logger,
  level: :debug

config :discordsworn, Discordsworn.Repo,
  database: "discordsworn",
  username: System.get_env("DISCORDSWORN_DB_USERNAME"),
  password: System.get_env("DISCORDSWORN_DB_PASSWORD"),
  hostname: "localhost"

config :discordsworn,
  ecto_repos: [Discordsworn.Repo],
  owner_discord_id: System.get_env("DISCORDSWORN_OWNER")
