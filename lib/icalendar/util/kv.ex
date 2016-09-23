defmodule ICalendar.Util.KV do
  @moduledoc """
  Build ICalendar key-value strings
  """

  @doc ~S"""
  Convert a key and value to an iCal line:

    iex> ICalendar.Util.KV.build("foo", "bar", "bar")
    "foo:bar\n"

  Don't add empty values:

    iex> ICalendar.Util.KV.build("foo", nil, nil)
    ""

  DateTime values will add timezones:

    iex> date =
    ...>   {{2015, 12, 24}, {8, 30, 0}}
    ...>   |> Timex.to_datetime("America/Chicago")
    ...> ICalendar.Util.KV.build("foo", "20151224T083000", date)
    "foo;TZID=America/Chicago:20151224T083000\n"
  """
  def build(_, nil, _) do
    ""
  end

  def build("LOCATION" = key, value, _raw) do
    build_sanitized(key, value)
  end

  def build("DESCRIPTION" = key, value, _raw) do
    build_sanitized(key, value)
  end

  def build(key, value, date = %DateTime{}) do
    "#{key};TZID=#{date.time_zone}:#{value}\n"
  end

  def build(key, value, _raw) do
    "#{key}:#{value}\n"
  end

  defp build_sanitized(key, value) do
    "#{key}:#{sanitize(value)}\n"
  end

  defp sanitize(string) when is_bitstring(string) do
    string
    |> String.replace(~r{([\,;])}, "//\\g{1}")
    |> String.replace("//", "\\")
  end

end
