defmodule Discordsworn.Dice do
  alias Discordsworn.Commands
  import Nostrum.Struct.Embed

  def ironsworn_action(args, msg, _state) do
    desc = Enum.join(args, " ")

    {mods_total, mods} = ironsworn_modifiers(desc)

    content = ~s"""
    #{Nostrum.Struct.User.mention(msg.author)}
    """

    embed = embed_ironsworn(desc, mods_total, mods)

    Nostrum.Api.create_message(msg.channel_id, content: content, embed: embed)
  end

  defp ironsworn_modifiers(description) do
    mods =
      case Regex.scan(~r/[+\-]?\d+/, description) do
        captures ->
          captures
          |> Enum.map(&hd/1)
          |> Enum.map(&Integer.parse(&1))
          |> Enum.map(&validate_integer/1)
      end

    {Enum.sum(mods), mods}
  end

  defp embed_ironsworn(description, modifiers_total, modifiers) do
    {act, challenge1, challenge2} = {roll(6), roll(10), roll(10)}

    total = act + modifiers_total

    challenge_dice =
      [challenge1, challenge2]
      |> Enum.map(&if total > &1, do: "__**#{&1}**__", else: "**#{&1}**")
      |> Enum.join(" & ")

    modifiers_field =
      modifiers
      |> Enum.reduce(
        "",
        &"#{&2}#{unless(&2 === "" || &1 < 0, do: "+", else: "")}#{&1}"
      )

    act_field = "**#{act}**"

    match = challenge1 === challenge2

    {success_field, color} =
      cond do
        total > challenge1 && total > challenge2 ->
          {unless(match, do: "**Strong hit!**", else: "**Strong __match__!**"), 0x00_7F_00}

        total > challenge1 || total > challenge2 ->
          {unless(match, do: "Weak hit.", else: "Weak __match__."), 0x7F_7F_00}

        true ->
          {unless(match, do: "_Miss..._", else: "_Miss and __match__..._"), 0x7F_00_00}
      end

    total_field = "**#{total}**"

    %Nostrum.Struct.Embed{}
    |> Commands.put_provider()
    |> put_description(description)
    |> put_field("Action", act_field, true)
    |> put_field("Modifiers", modifiers_field, true)
    |> put_field("Total", total_field, true)
    |> put_field("Challenge", challenge_dice, true)
    |> put_field("Result", success_field, false)
    |> put_color(color)
  end

  defp validate_integer(:error), do: 0
  defp validate_integer({int, _}), do: int
  defp roll(sides), do: Enum.random(1..sides)
end
