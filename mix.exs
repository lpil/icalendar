defmodule ICalendar.Mixfile do
  use Mix.Project

  @version "1.1.0"

  def project do
    [
      app: :icalendar,
      version: @version,
      elixir: "~> 1.8",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "ICalendar",
      source_url: "https://github.com/lpil/icalendar",
      description: "An ICalendar file generator",
      package: [
        maintainers: ["Louis Pilfold"],
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/lpil/icalendar"}
      ]
    ]
  end

  def application do
    [applications: [:timex]]
  end

  defp deps do
    [
      # Automatic test runner
      {:mix_test_watch, ">= 0.0.0", only: :dev},

      # Markdown processor
      {:earmark, "~> 1.3", only: [:dev, :test]},
      # Documentation generator
      {:ex_doc, "~> 0.19", only: [:dev, :test]},

      # For full timezone support
      {:timex, "~> 3.4"}
    ]
  end
end
