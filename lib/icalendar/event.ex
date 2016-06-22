defmodule ICalendar.Event do
  @moduledoc """
  Calendars have events.
  """

  defstruct summary:     nil,
            dtstart:     nil,
            dtend:       nil,
            description: nil,
            location:    nil
end

defimpl ICalendar.Serialize, for: ICalendar.Event do
  alias ICalendar.Util.KV
  alias ICalendar.Value

  def to_ics(event) do
    contents = to_kvs(event)
    """
    BEGIN:VEVENT
    #{contents}END:VEVENT
    """
  end

  defp to_kvs(event) do
    event
    |> Map.from_struct
    |> Enum.map(&to_kv/1)
    |> Enum.sort
    |> Enum.join
  end


  defp to_kv({key, raw_value}) do
    name  = key |> to_string |> String.upcase
    value = Value.to_ics( raw_value )
    KV.build( name, value )
  end
end
