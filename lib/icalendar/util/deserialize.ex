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
  This function is designed to parse iCal datetime strings into erlang dates.

  It should be able to handle dates from the past:

  iex> ICalendar.Util.Deserialize.to_date("19930407T153022Z")
  {{1993, 4, 7}, {15, 30, 22}}

  As well as the future:

  iex>  ICalendar.Util.Deserialize.to_date("39930407T153022Z")
  {{3993, 4, 7}, {15, 30, 22}}

  And should return nil for incorrect dates:

  iex> ICalendar.Util.Deserialize.to_date("1993/04/07")
  {:error, "Timestamp is not in the correct format: 1993/04/07"}

  """
  def to_date(date_string) do
    date_regex = ~S/(?<year>\d{4})(?<month>\d{2})(?<day>\d{2})/
    time_regex = ~S/(?<hour>\d{2})(?<minute>\d{2})(?<second>\d{2})/
    {:ok, regex} = Regex.compile("#{date_regex}T#{time_regex}Z")

    case Regex.named_captures(regex, date_string) do
      %{
        "year" => year, "month" => month, "day" => day,
        "hour" => hour, "minute" => minute, "second" => second} ->

        date = {
          String.to_integer(year), String.to_integer(month),
          String.to_integer(day)}

        time = {
          String.to_integer(hour), String.to_integer(minute),
          String.to_integer(second)}
        {date, time}

      _ -> {:error, "Timestamp is not in the correct format: #{date_string}"}
    end
  end
end
