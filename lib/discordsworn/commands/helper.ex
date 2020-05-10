defmodule Discordsworn.Commands.Helper do
  import Nostrum.Struct.Embed

  alias Nostrum.Struct.User

  @colours %{
    strong_hit: 0x00_7F_00,
    weak_hit: 0x7F_7F_00,
    miss: 0x7F_00_00
  }
  def reply_embed(msg, title, description) do
    embed =
      %Nostrum.Struct.Embed{}
      |> put_title(title)
      |> put_description(description)

    content = "<@#{msg.author.id}>"
    Nostrum.Api.create_message(msg.channel_id, embed: embed, content: content)
  end

  def put_provider(embed),
    do: put_provider(embed, "Discordsworn", "https://github.com/ribbanya/discordsworn-ex")

  def roll(sides), do: Enum.random(1..sides)
  def get_colour(key), do: @colours[key]

  def is_owner(%User{id: id}), do: is_owner(id)
  def is_owner(id), do: id === get_owner()

  def is_self(%User{id: id}), do: is_self(id)
  def is_self(id), do: id === Nostrum.Cache.Me.get()

  def get_owner() do
    [{_key, id}] = :ets.lookup(Discordsworn.Session, :owner_id)
    id
  end
end
