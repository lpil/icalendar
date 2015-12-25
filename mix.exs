defmodule ICalendar.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :icalendar,
      version: "0.0.1",
      elixir: "~> 1.1",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps,

      name: "ICalendar",
      source_url: "https://github.com/lpil/dogma",
      description: "An ICalendar file generator",
      package: [
        maintainers: ["Louis Pilfold"],
        licenses: ["MIT"],
        links: %{ "GitHub" => "https://github.com/lpil/icalendar" },
      ],
    ]
  end

  def application do
    [applications: []]
  end

  defp deps do
    [
      # Code style linter
      {:dogma, only: ~w(dev test)a},
      # Automatic test runner
      {:mix_test_watch, only: :dev},

      # Markdown processor
      {:earmark, only: :dev},
      # Documentation generator
      {:ex_doc, only: :dev},
    ]
  end
end
