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

  @mappings %{
    "SUMMARY" => :summary,
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
    |> Enum.join
  end

  defp to_kv({name, key}, event) do
    {:ok, value} = Map.fetch( event, key )
    KV.build( name, value )
  end
end
