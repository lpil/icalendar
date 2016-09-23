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
    [key, value] = String.split(line, ":", parts: 2, trim: true)
    {String.upcase(key), value}
  end

  def parse_attr({"DESCRIPTION", description}, acc) do
    %{acc | description: desanitized(description)}
  end
  def parse_attr({"DTSTART", dtstart}, acc) do
    {:ok, timestamp} = to_date(dtstart)
    %{acc | dtstart: timestamp}
  end
  def parse_attr({"DTEND", dtend}, acc) do
    {:ok, timestamp} = to_date(dtend)
    %{acc | dtend: timestamp}
  end
  def parse_attr({"SUMMARY", summary}, acc) do
    %{acc | summary: desanitized(summary)}
  end
  def parse_attr({"LOCATION", location}, acc) do
    %{acc | location: desanitized(location)}
  end
  def parse_attr(_, acc), do: acc

  @doc ~S"""
  This function is designed to parse iCal datetime strings into erlang dates.

  It should be able to handle dates from the past:

      iex> {:ok, date} = ICalendar.Util.Deserialize.to_date("19930407T153022Z")
      ...> Timex.to_erl(date)
      {{1993, 4, 7}, {15, 30, 22}}

  As well as the future:

      iex> {:ok, date} = ICalendar.Util.Deserialize.to_date("39930407T153022Z")
      ...> Timex.to_erl(date)
      {{3993, 4, 7}, {15, 30, 22}}

  And should return nil for incorrect dates:

      iex> ICalendar.Util.Deserialize.to_date("1993/04/07")
      {:error, "Expected `1-2 digit month` at line 1, column 5."}
  """
  def to_date(date_string) do
    # Force UTC until we add native timezone support
    date_string = date_string <> "UTC"
    Timex.parse(date_string, "{YYYY}{0M}{0D}T{h24}{m}{s}Z{Zname}")
  end

  @doc ~S"""

  This function should strip any sanitization that has been applied to content
  within an iCal string.

  iex> ICalendar.Util.Deserialize.desanitized(~s(lorem\\, ipsum))
  "lorem, ipsum"
  """
  def desanitized(string) do
    string
    |> String.replace(~s(\\), "")
  end
end
