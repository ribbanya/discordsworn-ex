defmodule Discordsworn.Commands do
  import Nostrum.Struct.Embed
  alias Discordsworn.Dice

  def execute(msg, state) do
    case parse_command(msg.content) do
      {cmd, args} when cmd in ["ironsworn-action", "is", "act", "a"] ->
        Dice.ironsworn_action(args, msg, state)
    end
  end

  defp parse_command(input) do
    [cmd | args] =
      input
      |> String.trim_leading(".")
      |> String.split(" ")

    {cmd, args}
  end

  def reply_embed(msg, title, description) do
    embed =
      %Nostrum.Struct.Embed{}
      |> put_title(title)
      |> put_description(description)

    content = "<@#{msg.author.id}>"
    Nostrum.Api.create_message(msg.channel_id, embed: embed, content: content)
  end

  def put_provider(embed), do: put_provider(embed, "Discordsworn", nil)
end
