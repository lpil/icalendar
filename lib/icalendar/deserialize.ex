defprotocol ICalendar.Deserialize do
  def from_ics(ics)
end

alias ICalendar.Deserialize

defimpl ICalendar.Deserialize, for: BitString do
  alias ICalendar.Util.Deserialize

  def from_ics(ics) do
    ics
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.trim_trailing/1)
    |> get_events()
  end

  defp get_events(calendar_data, event_collector \\ [], temp_collector \\ [])

  defp get_events([head | calendar_data], event_collector, temp_collector) do
    case head do
      "BEGIN:VEVENT" ->
        # start collecting event
        get_events(calendar_data, event_collector, [head])

      "END:VEVENT" ->
        # finish collecting event
        event = Deserialize.build_event(temp_collector ++ [head])
        get_events(calendar_data, [event] ++ event_collector, [])

      event_property when temp_collector != [] ->
        get_events(calendar_data, event_collector, temp_collector ++ [event_property])

      _unimportant_stuff ->
        get_events(calendar_data, event_collector, temp_collector)
    end
  end

  defp get_events([], event_collector, _temp_collector), do: event_collector
end
