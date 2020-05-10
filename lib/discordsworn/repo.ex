defmodule Discordsworn.Repo do
  use Ecto.Repo,
    otp_app: :discordsworn,
    adapter: Ecto.Adapters.Postgres
end
