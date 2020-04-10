defmodule Discordsworn.MixProject do
  use Mix.Project

  def project do
    [
      app: :discordsworn,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :ex_dice_roller]
    ]
  end

  @doc false
  def run(args) do
    Mix.Tasks.Run.run(["--no-halt"] ++ args)
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nostrum, "~> 0.4"},
      {:ex_dice_roller, "~> 1.0.0-rc.2"}
    ]
  end
end
