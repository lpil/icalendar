defmodule ICalendar.RRULETest do
  use ExUnit.Case
  alias ICalendar.RRULE
  doctest ICalendar.RRULE

  describe "deserialize" do

    test "String, Atom & Number properties" do
      [
        {"FREQ=DAILY",         %RRULE{frequency: :daily}},
        {"COUNT=5",            %RRULE{count: 5}},
        {"INTERVAL=5",         %RRULE{interval: 5}},
        {"BYSECOND=5",         %RRULE{by_second: [5]}},
        {"BYSECOND=5,10,15",   %RRULE{by_second: [5, 10, 15]}},
        {"BYMINUTE=5",         %RRULE{by_minute: [5]}},
        {"BYHOUR=5",           %RRULE{by_hour: [5]}},
        {"BYMONTH=5",          %RRULE{by_month: [:may]}},
        {"BYMONTH=1,3,5",      %RRULE{by_month: [:january, :march, :may]}},
        {"BYMONTHDAY=5",       %RRULE{by_month_day: [5]}},
        {"BYMONTHDAY=-5",      %RRULE{by_month_day: [-5]}},
        {"BYYEARDAY=5",        %RRULE{by_year_day: [5]}},
        {"BYWEEKNO=5",         %RRULE{by_week_number: [5]}},
        {"BYSETPOS=5",         %RRULE{by_set_pos: [5]}},
        {"FREQ=DAILY;COUNT=5", %RRULE{count: 5, frequency: :daily}},
        {"BYDAY=MO",           %RRULE{by_day: [:monday]}},
        {"BYDAY=MO,TU,SA",     %RRULE{by_day: [:monday, :tuesday, :saturday]}},
        {"WKST=MO",            %RRULE{week_start: :monday}},
        {"x-name=lorem",       %RRULE{x_name: "lorem"}}
      ]
      |> Enum.each(fn ({check, result}) ->
        assert RRULE.deserialize(check) == {:ok, result}
      end)
    end

    test "Complex Properties" do
      {:ok, rrule} =
        "UNTIL=19970714T133000"
        |> RRULE.deserialize

      assert rrule.until.time_zone == "Etc/UTC"
      assert Timex.to_erl(rrule.until) == {{1997, 7, 14}, {13, 30, 0}}
    end

    test "Validation" do
      [
        {"not_a_key=lorem",
         {:error, [
             "'NOT_A_KEY' is not a recognised property"
           ]}},

        {"not_a_key=lorem;also_not_a_key=ipsum",
           {:error, [
              "'ALSO_NOT_A_KEY' is not a recognised property",
              "'NOT_A_KEY' is not a recognised property"
             ]}},

        {"INTERVAL=0",
         {:error, [
             "'INTERVAL' must be >= 1 if it is set"
           ]}},

        {"COUNT=0",
          {:error, [
             "'COUNT' must be >= 1 if it is set"
            ]}},

        {"BYSECOND=-1",
          {:error, [
             "'BYSECOND' must be between 0 and 59 if it is set"
            ]}},

        {"BYSECOND=60",
           {:error, [
             "'BYSECOND' must be between 0 and 59 if it is set"
             ]}},

        {"BYMINUTE=-1",
           {:error, [
             "'BYMINUTE' must be between 0 and 59 if it is set"
             ]}},

        {"BYMINUTE=60",
         {:error, [
             "'BYMINUTE' must be between 0 and 59 if it is set"
           ]}},

        {"BYHOUR=-1",
         {:error, [
             "'BYHOUR' must be between 0 and 23 if it is set"
           ]}},

        {"BYHOUR=24",
         {:error, [
            "'BYHOUR' must be between 0 and 23 if it is set"
           ]}},

        {"BYMONTHDAY=-32",
         {:error, [
             "'BYMONTHDAY' must be between 1 and 31 or -1 and -31 if it is set"
           ]}},

        {"BYMONTHDAY=0",
         {:error, [
             "'BYMONTHDAY' must be between 1 and 31 or -1 and -31 if it is set"
           ]}},

        {"BYMONTHDAY=32",
         {:error, [
             "'BYMONTHDAY' must be between 1 and 31 or -1 and -31 if it is set"
           ]}},

        {"BYYEARDAY=-367",
         {:error, [
             "'BYYEARDAY' must be between 1 and 366 or -1 and -366 if it is set"
           ]}},

        {"BYYEARDAY=0",
         {:error, [
             "'BYYEARDAY' must be between 1 and 366 or -1 and -366 if it is set"
           ]}},

        {"BYYEARDAY=367",
         {:error, [
             "'BYYEARDAY' must be between 1 and 366 or -1 and -366 if it is set"
           ]}},

        {"BYWEEKNO=-54",
         {:error, [
             "'BYWEEKNO' must be between 1 and 53 or -1 and -53 if it is set"
           ]}},

        {"BYWEEKNO=0",
         {:error, [
             "'BYWEEKNO' must be between 1 and 53 or -1 and -53 if it is set"
           ]}},

        {"BYWEEKNO=54",
         {:error, [
             "'BYWEEKNO' must be between 1 and 53 or -1 and -53 if it is set"
           ]}},

        {"BYSETPOS=-367",
         {:error, [
             "'BYSETPOS' must be between 1 and 366 or -1 and -366 if it is set"
           ]}},

        {"BYSETPOS=0",
         {:error, [
             "'BYSETPOS' must be between 1 and 366 or -1 and -366 if it is set"
           ]}},

        {"BYSETPOS=367",
         {:error, [
             "'BYSETPOS' must be between 1 and 366 or -1 and -366 if it is set"
           ]}},

        {"BYDAY=blergh",
         {:error, [
             "'BYDAY' must have a valid day string if set"
           ]}},

        {"WKST=blergh",
         {:error, [
             "'WKST' must have a valid day string if set"
           ]}},

        {"BYMONTH=0",
         {:error, [
             "'BYMONTH' must be between 1 and 12 if it is set"
           ]}},

        {"BYMONTH=13",
         {:error, [
             "'BYMONTH' must be between 1 and 12 if it is set"
           ]}},

        {"COUNT=13;UNTIL=22221224T084500Z",
         {:error, [
             "You can only set UNTIL or COUNT: not both at the same time"
           ]}}
      ]
      |> Enum.each(fn ({check, result}) ->
        assert RRULE.deserialize(check) == result
      end)
    end

  end

end
