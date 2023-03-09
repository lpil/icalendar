defprotocol ICalendar.Deserialize do
  def from_ics(ics)
end

alias ICalendar.Deserialize

defimpl ICalendar.Deserialize, for: BitString do
  alias ICalendar.Util.Deserialize

  def from_ics(ics) do
    ics
    |> String.trim()
    |> adjust_wrapped_lines()
    |> String.split("\n")
    |> Enum.map(&String.trim_trailing/1)
    |> Enum.map(&String.replace(&1, ~S"\n", "\n"))
    |> get_events()
  end

  # Copy approach from Ruby library to deal with Google Calendar's wrapping
  # https://github.com/icalendar/icalendar/blob/14db8fdd36f9007fa2627b2c10a9cdf3c9f8f35a/lib/icalendar/parser.rb#L9-L22
  # See https://github.com/lpil/icalendar/issues/53 for discussion
  defp adjust_wrapped_lines(body) do
    String.replace(body, ~r/\r?\n[ \t]/, "")
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

      "BEGIN:" <> component_name when component_name not in ["VCALENDAR", "VEVENT"] ->
        # any other component is rejected
        {_, [_ | lines_rest]} =
          Enum.split_while(calendar_data, &(!match?("END:" <> ^component_name, &1)))

        get_events(lines_rest, event_collector, temp_collector)

      event_property when temp_collector != [] ->
        get_events(calendar_data, event_collector, temp_collector ++ [event_property])

      _unimportant_stuff ->
        get_events(calendar_data, event_collector, temp_collector)
    end
  end

  defp get_events([], event_collector, _temp_collector), do: event_collector
end
