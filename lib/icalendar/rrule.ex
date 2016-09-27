defmodule ICalendar.RRULE do
  @moduledoc """
  Serialize and deserialize RRULEs
  """

  alias ICalendar.Property
  alias ICalendar.Util.Deserialize

  @frequencies %{
    "SECONDLY" => :secondly,
    "MINUTELY" => :minutely,
    "HOURLY"   => :hourly,
    "DAILY"    => :daily,
    "WEEKLY"   => :weekly,
    "MONTHLY"  => :monthly,
    "YEARLY"   => :yearly
  }

  @days %{
    "SU" => :sunday,
    "MO" => :monday,
    "TU" => :tuesday,
    "WE" => :wednesday,
    "TH" => :thursday,
    "FR" => :friday,
    "SA" => :saturday
  }

  defstruct frequency: nil,
            until: nil,
            count: nil,
            interval: nil,
            by_second: [],      # integer >= 0 && <= 59
            by_minute: [],      # integer >= 0 && <= 59
            by_hour: [],        # integer >= 0 && <= 23
            by_week_day: [],    # %{ordinal: 0, day: nil}
            by_month_day: [],   # integer > 0 && < 32
            by_year_day:  [],   # integer > 0 && < 367
            by_week_number: [], # integer > 0 && < 32
            by_month: [],       # integer > 0 && < 13
            by_set_pos: [],     # integer > 0 && < 367
            week_start: nil,    # @days
            # TODO: Improve naming, find out what this does
            x_name: nil

  @doc ~S"""
  This function is used to deserialize an RRULE string into a struct

  Sending an RRULE deserializes it:

      iex> "FREQ=DAILY;COUNT=10"
      ...> |> ICalendar.RRULE.deserialize
      %ICalendar.RRULE{
        :frequency => :daily,
        :count     => 10
      }

  """
  def deserialize(rrule) when is_bitstring(rrule) do
    rrule
    |> String.split(";")
    |> Enum.map(fn (prop) ->
      [key, value] = String.split(prop, "=", parts: 2, trim: true)
      [key, params] = Deserialize.retrieve_params(key)

      %Property{key: String.upcase(key), value: value, params: params}
    end)
    |> Enum.reduce(%ICalendar.RRULE{}, &parse_attr/2)
  end

  def parse_attr(%Property{key: "FREQ", value: frequency}, accumulator) do
    frequency = String.upcase(frequency)
    frequency = Map.fetch!(@frequencies, frequency)
    %{ accumulator | frequency: frequency }
  end
  def parse_attr(%Property{key: "COUNT", value: count}, accumulator) do
    %{ accumulator | count: String.to_integer(count) }
  end
  def parse_attr(
    %Property{key: "UNTIL", params: params, value: until},
    accumulator
  ) do

    {:ok, date} = Deserialize.to_date(until, Map.merge(params, %{"TZID" => "Etc/UTC"}))
    %{ accumulator | until: date }
  end
  def parse_attr(%{key: key, value: value}, accumulator) do
    key =
      key
      |> String.downcase
      |> String.to_atom

    Map.put(accumulator, key, value)
  end

  def validate(rrule) do
    # UNTIL or COUNT may appear but not both
    # UNTIL is a date if set
    # COUNT is >= 1 if set

    rrule
  end

end
