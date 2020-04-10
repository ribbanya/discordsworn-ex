defmodule Discordsworn.Dice do
  alias Discordsworn.Commands
  import Nostrum.Struct.Embed

  def ironsworn_action(args, msg, _state) do
    desc = Enum.join(args, " ")

    {adds_total, adds} = ironsworn_adds(desc)

    content = ~s"""
    #{Nostrum.Struct.User.mention(msg.author)}
    """

    embed = embed_ironsworn(desc, adds_total, adds)

    Nostrum.Api.create_message(msg.channel_id, content: content, embed: embed)
  end

  defp ironsworn_adds(description) do
    adds =
      case Regex.scan(~r/[+\-]?\d+/, description) do
        captures ->
          captures
          |> Enum.map(&hd/1)
          |> Enum.map(&Integer.parse(&1))
          |> Enum.map(&validate_integer/1)
      end

    {Enum.sum(adds), adds}
  end

  defp embed_ironsworn(description, adds_total, adds) do
    {act, challenge1, challenge2} = {roll(6), roll(10), roll(10)}

    score =
      (act + adds_total)
      |> min(10)

    challenge_dice =
      [challenge1, challenge2]
      |> Enum.map(&if score > &1, do: "__**#{&1}**__", else: "**#{&1}**")
      |> Enum.join(" & ")

    adds_field =
      adds
      |> Enum.reduce(
        "",
        &"#{&2}#{unless(&2 === "" || &1 < 0, do: "+", else: "")}#{&1}"
      )

    act_field = "**#{act}**"

    match = challenge1 === challenge2

    {success_field, color} =
      cond do
        score > challenge1 && score > challenge2 ->
          {unless(match, do: "**Strong hit!**", else: "**Strong __match__!**"), 0x00_7F_00}

        score > challenge1 || score > challenge2 ->
          {unless(match, do: "Weak hit.", else: "Weak __match__."), 0x7F_7F_00}

        true ->
          {unless(match, do: "_Miss..._", else: "_Miss and __match__..._"), 0x7F_00_00}
      end

    score_field = "**#{score}**"

    %Nostrum.Struct.Embed{}
    |> Commands.put_provider()
    |> put_description(description)
    |> put_field("Roll", act_field, true)
    |> put_field("Adds", adds_field, true)
    |> put_field("Score", score_field, true)
    |> put_field("Challenge", challenge_dice, true)
    |> put_field("Result", success_field, false)
    |> put_color(color)
  end

  defp validate_integer(:error), do: 0
  defp validate_integer({int, _}), do: int
  defp roll(sides), do: Enum.random(1..sides)
end
