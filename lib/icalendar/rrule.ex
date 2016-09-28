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

  @months [:january, :february, :march,
           :april, :may, :june, :july,
           :august, :september, :october,
           :november, :december]

  defstruct frequency: nil,
            until: nil,
            count: nil,
            interval: nil,
            by_day: [],
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
  def parse_attr(%Property{key: "INTERVAL", value: interval}, accumulator) do
    %{ accumulator | interval: String.to_integer(interval) }
  end
  def parse_attr(%Property{key: "BYSECOND", value: seconds}, accumulator) do
    seconds =
      seconds
      |> parse_value_as_list(&(String.to_integer(&1)))

    %{ accumulator | by_second: seconds }
  end
  def parse_attr(%Property{key: "BYMINUTE", value: minutes}, accumulator) do
    minutes =
      minutes
      |> parse_value_as_list(&(String.to_integer(&1)))

    %{ accumulator | by_minute: minutes }
  end
  def parse_attr(%Property{key: "BYHOUR", value: hours}, accumulator) do
    hours =
      hours
      |> parse_value_as_list(&(String.to_integer(&1)))

    %{ accumulator | by_hour: hours }
  end
  def parse_attr(
    %Property{key: "BYMONTHDAY", value: month_days},
    accumulator
  ) do
    month_days =
      month_days
      |> parse_value_as_list(&(String.to_integer(&1)))

    %{ accumulator | by_month_day: month_days }
  end
  def parse_attr(
    %Property{key: "BYYEARDAY", value: year_days},
    accumulator
  ) do
    year_days =
      year_days
      |> parse_value_as_list(&(String.to_integer(&1)))

    %{ accumulator | by_year_day: year_days }
  end
  def parse_attr(
    %Property{key: "BYWEEKNO", value: week_numbers},
    accumulator
  ) do
    week_numbers =
      week_numbers
      |> parse_value_as_list(&(String.to_integer(&1)))

    %{ accumulator | by_week_number: week_numbers }
  end
  def parse_attr(%Property{key: "BYSETPOS", value: set_pos}, accumulator) do
    set_pos =
      set_pos
      |> parse_value_as_list(&(String.to_integer(&1)))

    %{ accumulator | by_set_pos: set_pos }
  end
  def parse_attr(
    %Property{key: "UNTIL", params: params, value: until},
    accumulator
  ) do

    {:ok, date} = Deserialize.to_date(
      until,
      Map.merge(params, %{"TZID" => "Etc/UTC"})
    )
    %{ accumulator | until: date }
  end
  def parse_attr(
    %Property{key: "BYDAY", value: days},
    accumulator
  ) do
    days =
      days
      |> parse_value_as_list(
        &(Map.fetch!(@days, String.upcase(&1)))
      )

    %{ accumulator | by_day: days }
  end
  def parse_attr(
    %Property{key: "BYMONTH", value: months},
    accumulator
  ) do
    months =
      months
      |> parse_value_as_list(
        &(Enum.at(@months, (String.to_integer(&1) - 1)))
      )

    %{ accumulator | by_month: months }
  end
  def parse_attr(
    %Property{key: "WKST", value: week_start},
    accumulator
  ) do
    week_start =
      Map.fetch!(@days, String.upcase(week_start))
    %{ accumulator | week_start: week_start}
  end
  def parse_attr(
    %Property{key: "X-NAME", value: value},
    accumulator
  ) do
    %{ accumulator | x_name: value}
  end
  def parse_attr(%{key: key, value: value}, accumulator) do
    key =
      key
      |> String.downcase
      |> String.to_atom

    Map.put(accumulator, key, value)
  end

  @doc """
  This function is used to split up values into a list format. An operation is
  optionally passed to it to format each result in a certain way.

      iex> RRULE.parse_value_as_list("a,b,c")
      ["a", "b", "c"]

      iex> RRULE.parse_value_as_list("1,2,3", &(String.to_integer(&1)))
      [1,2,3]
  """
  def parse_value_as_list(value), do: parse_value_as_list(value, &(&1))
  def parse_value_as_list(value, operation) when is_function(operation) do
    vals =
      value
      |> String.split(",")

    vals
    |> is_bitstring
    |> case do
        true -> [vals]
        false -> vals
      end
    |> Enum.map(operation)
  end

  def validate(rrule) do
    # UNTIL or COUNT may appear but not both
    # UNTIL is a date if set
    # COUNT is >= 1 if set

    rrule
  end

end
