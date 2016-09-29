defmodule ICalendar.Util.Deserialize do
  @moduledoc """
  Deserialize ICalendar Strings into Event structs
  """

  alias ICalendar.Event
  alias ICalendar.Property
  alias ICalendar.RRULE

  def invert_map(map = %{}) do
    map
    |> Enum.reduce(%{}, fn({key, value}, acc) ->
      Map.put(acc, value, key)
    end)
  end


  def build_event(lines) when is_list(lines) do
    lines
    |> Enum.map(&retrieve_kvs/1)
    |> Enum.reduce(%Event{}, &parse_attr/2)
  end

  @doc ~S"""
  This function extracts the key and value parts from each line of a iCalendar
  string.

      iex> ICalendar.Util.Deserialize.retrieve_kvs("lorem:ipsum")
      %ICalendar.Property{key: "LOREM", params: %{}, value: "ipsum"}
  """
  def retrieve_kvs(line) do
    # Split Line up into key and value
    [key, value] = String.split(line, ":", parts: 2, trim: true)
    [key, params] = retrieve_params(key)

    %Property{key: String.upcase(key), value: value, params: params}
  end

  @doc ~S"""
  This function extracts parameter data from a key in an iCalendar string.

      iex> ICalendar.Util.Deserialize.retrieve_params(
      ...>   "DTSTART;TZID=America/Chicago")
      ["DTSTART", %{"TZID" => "America/Chicago"}]

  It should be able to handle multiple parameters per key:

      iex> ICalendar.Util.Deserialize.retrieve_params(
      ...>   "KEY;LOREM=ipsum;DOLOR=sit")
      ["KEY", %{"LOREM" => "ipsum", "DOLOR" => "sit"}]
  """
  def retrieve_params(key) do
    [key | params] = String.split(key, ";", trim: true)

    params =
      params
      |> Enum.reduce(%{}, fn(param, acc) ->
        [key, val] = String.split(param, "=", parts: 2, trim: true)
        Map.merge(acc, %{key => val})
      end)

    [key, params]
  end

  def parse_attr(
    %Property{key: "DESCRIPTION", value: description},
    acc
  ) do
    %{acc | description: desanitized(description)}
  end
  def parse_attr(
    %Property{key: "DTSTART", value: dtstart, params: params},
    acc
  ) do
    {:ok, timestamp} = to_date(dtstart, params)
    %{acc | dtstart: timestamp}
  end
  def parse_attr(
    %Property{key: "DTEND", value: dtend, params: params},
    acc
  ) do
    {:ok, timestamp} = to_date(dtend, params)
    %{acc | dtend: timestamp}
  end
  def parse_attr(
    %Property{key: "SUMMARY", value: summary},
    acc
  ) do
    %{acc | summary: desanitized(summary)}
  end
  def parse_attr(
    %Property{key: "LOCATION", value: location},
    acc
  ) do
    %{acc | location: desanitized(location)}
  end
  def parse_attr(
    %Property{key: "RRULE", value: rrule},
    acc
  ) do
    %{acc | rrule: RRULE.deserialize(rrule)}
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

  It should handle timezones from  the Olson Database:

      iex> {:ok, date} = ICalendar.Util.Deserialize.to_date("19980119T020000",
      ...> %{"TZID" => "America/Chicago"})
      ...> [Timex.to_erl(date), date.time_zone]
      [{{1998, 1, 19}, {2, 0, 0}}, "America/Chicago"]
  """
  def to_date(date_string, %{"TZID" => timezone}) do
    date_string =
      case String.last(date_string) do
        "Z" -> date_string
        _   -> date_string <> "Z"
      end

    Timex.parse(date_string <> timezone, "{YYYY}{0M}{0D}T{h24}{m}{s}Z{Zname}")
  end

  def to_date(date_string, %{}) do
    to_date(date_string, %{"TZID" => "Etc/UTC"})
  end

  def to_date(date_string) do
    to_date(date_string, %{"TZID" => "Etc/UTC"})
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
