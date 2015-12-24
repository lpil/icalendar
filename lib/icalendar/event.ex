defmodule ICalendar.Event do
  @moduledoc """
  Calendars have events.
  """

  defstruct summary:     nil,
            start:       nil,
            finish:      nil,
            description: nil
end

defimpl ICalendar.Serialize, for: ICalendar.Event do
  alias ICalendar.Util.KV
  alias ICalendar.Value

  @mappings %{
    description: "DESCRIPTION",
    summary:     "SUMMARY",
    start:       "DTSTART",
    finish:      "DTEND",
  }

  def to_ics(event) do
    contents = to_kvs(event)
    """
    BEGIN:VEVENT
    #{contents}END:VEVENT
    """
  end

  defp to_kvs(event) do
    @mappings
    |> Enum.map(&to_kv(&1, event))
    |> Enum.sort
    |> Enum.join
  end

  defp to_kv({key, name}, event) do
    {:ok, raw_value} = Map.fetch( event, key )
    value = Value.to_ics( raw_value )
    KV.build( name, value )
  end
end
