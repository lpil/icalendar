defmodule ICalendar.RRULETest do
  use ExUnit.Case
  alias ICalendar.RRULE
  doctest ICalendar.RRULE

  describe "deserialize" do

    test "String, Atom & Number properties" do
      [
        {"FREQ=DAILY",         %RRULE{frequency: :daily}},
        {"FREQ=yearly",        %RRULE{frequency: :yearly}},
        {"COUNT=5",            %RRULE{count: 5}},
        {"INTERVAL=5",         %RRULE{interval: 5}},
        {"BYSECOND=5",         %RRULE{by_second: [5]}},
        {"BYSECOND=5,10,15",   %RRULE{by_second: [5, 10, 15]}},
        {"BYMINUTE=5",         %RRULE{by_minute: [5]}},
        {"BYHOUR=5",           %RRULE{by_hour: [5]}},
        {"BYMONTHDAY=5",       %RRULE{by_month_day: [5]}},
        {"BYMONTHDAY=-5",      %RRULE{by_month_day: [-5]}},
        {"BYYEARDAY=5",        %RRULE{by_year_day: [5]}},
        {"BYWEEKNO=5",         %RRULE{by_week_number: [5]}},
        {"BYSETPOS=5",         %RRULE{by_set_pos: [5]}},
        {"FREQ=DAILY;COUNT=5", %RRULE{count: 5, frequency: :daily}}
      ]
      |> Enum.each(fn ({check, result}) ->
        assert RRULE.deserialize(check) == result
      end)
    end

    test "Complex Properties" do
      rrule =
        "UNTIL=19970714T133000"
        |> RRULE.deserialize

      assert rrule.until.time_zone == "Etc/UTC"
      assert Timex.to_erl(rrule.until) == {{1997, 7, 14}, {13, 30, 0}}
    end

  end

end
