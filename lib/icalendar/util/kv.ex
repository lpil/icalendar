defmodule ICalendar.Util.KV do
  @moduledoc """
  Build ICalendar key-value strings
  """

  alias ICalendar.Value

  @doc ~S"""
  Convert a key and value to an iCal line:

    iex> ICalendar.Util.KV.build("foo", "bar")
    "foo:bar\n"

  Don't add empty values:

    iex> ICalendar.Util.KV.build("foo", nil)
    ""

  DateTime values will add timezones:

    iex> date =
    ...>   {{2015, 12, 24}, {8, 30, 0}}
    ...>   |> Timex.to_datetime("America/Chicago")
    ...> ICalendar.Util.KV.build("foo", date)
    "foo;TZID=America/Chicago:20151224T083000\n"
  """
  def build(_, nil) do
    ""
  end

  def build("LOCATION" = key, value) do
    build_sanitized(key, Value.to_ics(value))
  end

  def build("DESCRIPTION" = key, value) do
    build_sanitized(key, Value.to_ics(value))
  end

  def build("CATEGORIES", value) do
    "CATEGORIES:#{Enum.join(Value.to_ics(value), ",")}\n"
  end

  def build("STATUS" = key, value) do
    build_sanitized(key, Value.to_ics(value |> to_string |> String.upcase()))
  end

  def build("CLASS" = key, value) do
    build_sanitized(key, Value.to_ics(value |> to_string |> String.upcase()))
  end

  def build("GEO" = key, {lat, lon}) do
    "#{key}:#{lat};#{lon}\n"
  end

  def build(key, date = %DateTime{time_zone: "Etc/UTC"}) do
    "#{key}:#{Value.to_ics(date)}Z\n"
  end

  def build(key, date = %DateTime{}) do
    "#{key};TZID=#{date.time_zone}:#{Value.to_ics(date)}\n"
  end

  def build(key, value) do
    "#{key}:#{Value.to_ics(value)}\n"
  end

  defp build_sanitized(key, value) do
    "#{key}:#{sanitize(value)}\n"
  end

  defp sanitize(string) when is_bitstring(string) do
    string
    |> String.replace(~r{([\,;])}, "\\\\\\g{1}")
  end
end
