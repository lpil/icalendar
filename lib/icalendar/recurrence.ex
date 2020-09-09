defmodule ICalendar.Recurrence do
  @moduledoc """
  Adds support for recurring events.
  Events can recur by frequency, count, interval, and/or start/end date. To
  see the specific rules and examples, see `add_recurring_events/2` below.

  Credit to @fazibear for this module
  """

  alias ICalendar.Event

  # ignore :bysecond, :minute for now
  @by_x_rrules [:byhour, :byday, :monthday, :byyearday, :byweekno, :bymonth]

  @day_values %{su: 0, mo: 1, tu: 2, we: 3, th: 4, fr: 5, sa: 6}

  @doc """
  Add recurring events to events list
  ## Parameters
    - `events`: List of events that each may contain an rrule. See `ICalendar.Event`.
    - `end_date` *(optional)*: A date time that represents the fallback end date
      for a recurring event. This value is only used when the options specified
      in rrule result in an infinite recurrance (ie. when neither `count` nor
      `until` is set). If no end_date is set, it will default to
      `DateTime.utc_now()`.
  ## Event rrule options
    Event recurrance details are specified in the `rrule`. The following options
    are considered:
    - `freq`: Represents how frequently the event recurs. Allowed frequencies
      are `DAILY`, `WEEKLY`, and `MONTHLY`. These can be further modified by
      the `interval` option.
    - `count` *(optional)*: Represents the number of times that an event will
      recur. This takes precedence over the `end_date` parameter and the
      `until` option.
    - `interval` *(optional)*: Represents the interval at which events occur.
      This option works in concert with `freq` above; by using the `interval`
      option, an event could recur every 5 days or every 3 weeks.
    - `until` *(optional)*: Represents the end date for a recurring event.
      This takes precedence over the `end_date` parameter.
    The `freq` option is required for a valid rrule, but the others are
    optional. They may be used either individually (ex. just `freq`) or in
    concert (ex. `freq` + `interval` + `until`).
  ## Examples
      iex> dt = Timex.Date.from({2016,8,13})
      iex> dt_end = Timex.Date.from({2016, 8, 23})
      iex> events = [%ICalendar.Event{rrule:%{freq: "DAILY"}, dtstart: dt, dtend: dt}]
      iex> ICalendar.Recurrence.add_recurring_event(events, dt_end) |> length
      10
  """

  @spec add_recurring_events([%Event{}]) :: [%Event{}]
  @spec add_recurring_events([%Event{}], %DateTime{}) :: [%Event{}]
  def add_recurring_events(events, end_date \\ DateTime.utc_now()) do
    event_recurrences =
      events
      |> Enum.reduce([], fn event, revents ->
        reference_events =
          if is_map(event.rrule) && Map.take(event.rrule, @by_x_rrules) != %{} do
            # If there are any by_x modifiers in the rrule, handle them
            case event.rrule do
              %{byday: bydays} ->
                bydays
                |> Enum.map(fn byday ->
                  day_atom = byday |> String.downcase() |> String.to_atom()

                  event_day_of_week_number = Map.get(@day_values, day_atom)

                  if is_nil(event_day_of_week_number),
                    do:
                      raise(
                        ICalendar.Recurrence.RecurrenceError,
                        "Invalid rrule byday value: #{byday}"
                      )

                  # determine the difference between the byday and the event's dtstart
                  day_offset_for_reference =
                    event_day_of_week_number - Timex.weekday(event.dtstart)

                  #  Remove the invalid reference events later on
                  Map.merge(event, %{
                    dtstart: Timex.shift(event.dtstart, days: day_offset_for_reference),
                    dtend: Timex.shift(event.dtend, days: day_offset_for_reference)
                  })
                end)
            end
          else
            [event]
          end

        Enum.map(reference_events, fn reference_event ->
          new_events =
            case event.rrule do
              nil ->
                nil

              %{freq: "DAILY", count: count, interval: interval} ->
                reference_event |> add_recurring_events_count(count, days: interval)

              %{freq: "DAILY", until: until, interval: interval} ->
                reference_event |> add_recurring_events_until(until, days: interval)

              %{freq: "DAILY", count: count} ->
                reference_event |> add_recurring_events_count(count, days: 1)

              %{freq: "DAILY", until: until} ->
                reference_event |> add_recurring_events_until(until, days: 1)

              %{freq: "DAILY", interval: interval} ->
                reference_event |> add_recurring_events_until(end_date, days: interval)

              %{freq: "DAILY"} ->
                reference_event |> add_recurring_events_until(end_date, days: 1)

              %{freq: "WEEKLY", until: until, interval: interval} ->
                reference_event |> add_recurring_events_until(until, days: interval * 7)

              %{freq: "WEEKLY", count: count} ->
                reference_event |> add_recurring_events_count(count, days: 7)

              %{freq: "WEEKLY", until: until} ->
                reference_event |> add_recurring_events_until(until, days: 7)

              %{freq: "WEEKLY", interval: interval} ->
                reference_event |> add_recurring_events_until(end_date, days: interval * 7)

              %{freq: "WEEKLY"} ->
                reference_event |> add_recurring_events_until(end_date, days: 7)

              %{freq: "MONTHLY", count: count, interval: interval} ->
                reference_event |> add_recurring_events_count(count, months: interval)

              %{freq: "MONTHLY", until: until, interval: interval} ->
                reference_event |> add_recurring_events_until(until, months: interval)

              %{freq: "MONTHLY", count: count} ->
                reference_event |> add_recurring_events_count(count, months: 1)

              %{freq: "MONTHLY", until: until} ->
                reference_event |> add_recurring_events_until(until, months: 1)

              %{freq: "MONTHLY", interval: interval} ->
                reference_event |> add_recurring_events_until(end_date, months: interval)

              %{freq: "MONTHLY"} ->
                reference_event |> add_recurring_events_until(end_date, months: 1)

              %{freq: "YEARLY", count: count, interval: interval} ->
                reference_event |> add_recurring_events_count(count, years: interval)

              %{freq: "YEARLY", until: until, interval: interval} ->
                reference_event |> add_recurring_events_until(until, years: interval)

              %{freq: "YEARLY", count: count} ->
                reference_event |> add_recurring_events_count(count, years: 1)

              %{freq: "YEARLY", until: until} ->
                reference_event |> add_recurring_events_until(until, years: 1)

              %{freq: "YEARLY", interval: interval} ->
                reference_event |> add_recurring_events_until(end_date, years: interval)

              %{freq: "YEARLY"} ->
                reference_event |> add_recurring_events_until(end_date, years: 1)
            end
            |> Enum.filter(fn new_event ->
              # Make sure new event doesn't fall on an EXDATE
              falls_on_exdate = not is_nil(new_event) and new_event.dtstart in new_event.exdates

              #  This removes any events which were created as references
              is_invalid_reference_event =
                DateTime.compare(new_event.dtstart, event.dtstart) == :lt

              !falls_on_exdate && !is_invalid_reference_event
            end)

          revents ++ new_events
        end)
        |> List.flatten()
      end)
      |> Enum.sort_by(& &1.dtstart, {:asc, DateTime})

    events ++ event_recurrences
  end

  defp add_recurring_events_until(event, until, shift_opts) do
    new_event = shift_event(event, shift_opts)

    case Timex.compare(new_event.dtstart, until) do
      -1 -> [new_event] ++ add_recurring_events_until(new_event, until, shift_opts)
      0 -> [new_event]
      1 -> []
    end
  end

  defp add_recurring_events_count(event, count, shift_opts) do
    new_event = shift_event(event, shift_opts)

    if count > 1 do
      [new_event] ++ add_recurring_events_count(new_event, count - 1, shift_opts)
    else
      [new_event]
    end
  end

  defp shift_event(event, shift_opts) do
    new_event = event
    new_event = %{new_event | dtstart: shift_date(event.dtstart, shift_opts)}
    new_event = %{new_event | dtend: shift_date(event.dtend, shift_opts)}
    new_event
  end

  defp shift_date(date, shift_opts) do
    case Timex.shift(date, shift_opts) do
      %Timex.AmbiguousDateTime{} = new_date ->
        new_date.after

      new_date ->
        new_date
    end
  end

  defmodule RecurrenceError do
    defexception message: "An error occurred while building event recurrences"
  end
end
