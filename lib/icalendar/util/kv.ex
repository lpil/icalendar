defmodule ICalendar.Util.KV do
  @moduledoc """
  Build ICalendar key-value strings
  """

  @doc ~S"""
    iex> ICalendar.Util.KV.build("foo", "bar")
    "foo:bar\n"

    iex> ICalendar.Util.KV.build("foo", nil)
    ""
  """
  def build(_, nil) do
    ""
  end

  def build("LOCATION" = key, value ) do
    build_sanitized(key,value)
  end

  def build("DESCRIPTION" = key, value ) do
    build_sanitized(key,value)
  end

  def build(key, value) do
    "#{key}:#{value}\n"
  end

  defp build_sanitized(key, value) do
    "#{key}:#{sanitize(value)}\n"
  end

  defp sanitize(string) do
    string
    |> String.replace(~r{([\,;])}, "//\\g{1}")
    |> String.replace("//", "\\")
  end

end
