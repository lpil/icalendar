defprotocol ICalendar.Deserialize do
  def from_ics(ics, opts \\ [])
end

alias ICalendar.Deserialize

defimpl ICalendar.Deserialize, for: BitString do
  alias ICalendar.Util.Deserialize
  require Logger

  def from_ics(ics, opts \\ []) do
    ics
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.trim_trailing/1)
    |> get_events([], [], opts)
  end

  defp get_events(calendar_data, event_collector, temp_collector, opts)

  defp get_events([head | calendar_data], event_collector, temp_collector, opts) do
    case head do
      "BEGIN:VEVENT" ->
        # start collecting event
        get_events(calendar_data, event_collector, [head], opts)

      "END:VEVENT" ->
        # finish collecting event
        try do
          event = Deserialize.build_event(temp_collector ++ [head])
          get_events(calendar_data, [event] ++ event_collector, [], opts)
        rescue
          e ->
            if Keyword.get(opts, :ignore_errors) do
              Logger.info("Error parsing: #{inspect(e)}")
              get_events(calendar_data, event_collector, [], opts)
            else
              Kernel.reraise(e, __STACKTRACE__)
            end
        end

      event_property when temp_collector != [] ->
        get_events(calendar_data, event_collector, temp_collector ++ [event_property], opts)

      _unimportant_stuff ->
        get_events(calendar_data, event_collector, temp_collector, opts)
    end
  end

  defp get_events([], event_collector, _temp_collector, _opts), do: event_collector

end
