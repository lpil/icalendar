defmodule ICalendar.Util.Deserialize do
  @moduledoc """
  Deserialize ICalendar Strings into Event structs
  """

  alias ICalendar.Event

  def build_event(lines) when is_list(lines) do
    lines
    |> Enum.map(&retrieve_kvs/1)
    |> Enum.reduce(%Event{}, &parse_attr/2)
  end

  @doc ~S"""
  iex> ICalendar.Util.Deserialize.retrieve_kvs("lorem:ipsum")
  {"LOREM", "ipsum"}
  """
  def retrieve_kvs(line) do
    [key, value] = String.split(line, ":")
    {String.upcase(key), value}
  end

  def parse_attr({"DESCRIPTION", description}, acc) do
    %{acc | description: description}
  end
  def parse_attr({"DTSTART", dtstart}, acc) do
    %{acc | dtstart: to_date(dtstart)}
  end
  def parse_attr({"DTEND", dtend}, acc), do: %{acc | dtend: to_date(dtend)}
  def parse_attr({"SUMMARY", summary}, acc), do: %{acc | summary: summary}
  def parse_attr(_, acc), do: acc

  @doc ~S"""
  iex> ICalendar.Util.Deserialize.to_date("19930407T153022Z")
  {{1993, 4, 7}, {15, 30, 22}}
  """
  def to_date(date_string) do

    [date, time] =
      date_string
      |> String.upcase
      |> String.split(["T", "Z"], trim: true)

    year =
      date
      |> String.slice(0..3)
      |> String.to_integer

    month =
      date
      |> String.slice(4..5)
      |> String.to_integer

    day =
      date
      |> String.slice(6..7)
      |> String.to_integer

    hour =
      time
      |> String.slice(0..1)
      |> String.to_integer

    minute =
      time
      |> String.slice(2..3)
      |> String.to_integer

    second =
      time
      |> String.slice(4..5)
      |> String.to_integer

    {{year, month, day}, {hour, minute, second}}
  end

end
