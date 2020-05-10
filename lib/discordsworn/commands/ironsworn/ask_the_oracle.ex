defmodule Discordsworn.Commands.Ironsworn.AskTheOracle do
  @behaviour Nosedrum.Command
  @moduledoc false

  alias Nostrum.Struct.{Embed, User}
  alias Discordsworn.Commands.Helper
  import Nostrum.Struct.Embed

  @likelihoods %{
    0 => {"Certain", []},
    10 => {"Almost Certain", ["almost certain", "ac"]},
    25 => {"Likely", ["likely", "l"]},
    50 => {"50/50", ["50 50", "fifty fifty", "ff", "f"]},
    75 => {"Unlikely", ["unlikely", "ul"]},
    90 => {"Small Chance", ["small chance", "sc"]},
    100 => {"Impossible", []}
  }

  @impl true
  def usage, do: ["TODO"]

  @impl true
  def description, do: "TODO"

  @impl true
  def predicates, do: []

  @impl true
  def parse_args(args) do
    args
    |> Enum.join(" ")
    |> parse_likelihood()
  end

  defp parse_likelihood(string) do
    with [_, int] <- Regex.run(~r/([-\d.]+)%?\b/, string),
         {int, _} <- Integer.parse(int) do
      {:ok, int}
    else
      _ -> parse_string_likelihood(string)
    end
  end

  defp parse_string_likelihood(string) do
    string =
      string
      |> String.downcase()
      |> String.replace(~r/[-_\/]/, " ")

    @likelihoods
    |> Enum.find(fn {_int, {_label, aliases}} ->
      Enum.any?(aliases, &String.equivalent?(string, &1))
    end)
    |> case do
      {int, _pair} -> {:ok, int}
      err -> {:error, err}
    end
  end

  defp get_category(likelihood) do
    {category, _aliases} = @likelihoods[likelihood] || {"Custom (**#{100 - likelihood}**%)", []}
    category
  end

  @impl true
  def command(msg, likelihood) do
    {:ok, _msg} = reply(msg, likelihood)
  end

  defp reply(msg, likelihood) do
    embed = get_embed(msg, likelihood)

    Nostrum.Api.create_message(msg.channel_id, content: User.mention(msg.author), embed: embed)
  end

  defp get_embed(_msg, {:ok, likelihood}) do
    {result, success?, match?} = roll(likelihood)

    likelihood_field = if success?, do: "__**#{likelihood}**__", else: "**#{likelihood}**"

    %Embed{}
    |> Helper.put_provider()
    |> put_description("Ask the Oracle")
    |> put_field("Category", "#{get_category(likelihood)}", true)
    |> put_field("Roll", "**#{result}** vs. #{likelihood_field}", true)
    |> put_field("Result", if(success?, do: "**Yes!**", else: "No."), false)
    |> put_color(Helper.get_colour(if success?, do: :strong_hit, else: :miss))
  end

  defp roll(likelihood) do
    likelihood =
      likelihood
      |> max(0)
      |> min(100)

    [tens, ones] = ExDiceRoller.roll("2d10", opts: [:keep, :cache])
    result = tens * 10 + ones
    success? = result > likelihood
    match? = tens == ones
    {result, success?, match?}
  end
end
