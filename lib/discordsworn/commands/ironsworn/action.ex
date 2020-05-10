defmodule Discordsworn.Commands.Ironsworn.Action do
  @behaviour Nosedrum.Command
  @moduledoc false

  alias Nostrum.Struct.{Embed, User}
  import Nostrum.Struct.Embed
  import Discordsworn.Commands.Helper

  @impl true
  def usage, do: ["TODO"]

  @impl true
  def description, do: "TODO"

  @impl true
  def predicates, do: []

  @impl true
  def parse_args(args), do: Enum.join(args, " ")

  @impl true
  def command(msg, args) do
    {:ok, _msg} = reply(msg, args)
  end

  def reply(msg, args) do
    {adds_total, adds} = parse_adds(args)

    content = User.mention(msg.author)

    embed = get_embed(adds_total, adds)

    Nostrum.Api.create_message(msg.channel_id, content: content, embed: embed)
  end

  defp parse_adds(args) do
    adds =
      case Regex.scan(~r/[+\-]?\d+/, args) do
        captures ->
          captures
          |> Enum.map(&hd/1)
          |> Enum.map(&Integer.parse(&1))
          |> Enum.map(&validate_integer/1)
      end

    {Enum.sum(adds), adds}
  end

  defp get_embed(adds_total, adds) do
    {act, challenge1, challenge2} = {roll(6), roll(10), roll(10)}

    score =
      (act + adds_total)
      |> min(10)

    challenge_field =
      [challenge1, challenge2]
      |> Enum.map(&if score > &1, do: "__**#{&1}**__", else: "**#{&1}**")
      |> Enum.join(" & ")

    adds_field =
      adds
      |> case do
        [] ->
          ""

        not_empty ->
          combined = Enum.reduce(not_empty, "", &"#{&2}#{unless(&1 < 0, do: "+", else: "")}#{&1}")

          " (**#{act}**#{combined})"
      end

    roll_field = "**#{score}**#{adds_field} vs. #{challenge_field}"

    match = challenge1 === challenge2

    {success_field, colour_key} =
      cond do
        score > challenge1 && score > challenge2 ->
          {unless(match, do: "**Strong hit!**", else: "**Strong __match__!**"), :strong_hit}

        score > challenge1 || score > challenge2 ->
          {unless(match, do: "Weak hit.", else: "Weak __match__."), :weak_hit}

        true ->
          {unless(match, do: "_Miss..._", else: "_Miss and __match__..._"), :miss}
      end

    %Embed{}
    |> put_provider()
    |> put_description("Ironsworn Action")
    |> put_field("Roll", roll_field, true)
    |> put_field("Result", success_field, false)
    |> put_color(get_colour(colour_key))
  end

  defp validate_integer({int, _}), do: int
  defp validate_integer(:error), do: 0
end
