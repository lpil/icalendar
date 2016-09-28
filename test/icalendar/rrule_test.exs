defmodule ICalendar.RRULETest do
  use ExUnit.Case
  alias ICalendar.RRULE
  doctest ICalendar.RRULE

  describe "deserialize" do

    test "frequency" do
      [
        {"FREQ=DAILY", %RRULE{frequency: :daily}},
        {"FREQ=MONTHLY", %RRULE{frequency: :monthly}},
        {"FREQ=YEARLY", %RRULE{frequency: :yearly}},
        {"FREQ=yearly", %RRULE{frequency: :yearly}}
      ]
      |> Enum.each(fn ({check, result}) ->
        assert RRULE.deserialize(check) == result
      end)
    end

    test "count" do
      [
        {"FREQ=DAILY", %RRULE{count: nil, frequency: :daily}},
        {"COUNT=5", %RRULE{count: 5}},
        {"FREQ=DAILY;COUNT=3", %RRULE{count: 3, frequency: :daily}}
      ]
      |> Enum.each(fn ({check, result}) ->
        assert RRULE.deserialize(check) == result
      end)
    end

    test "until" do
      rrule =
        "UNTIL=19970714T133000"
        |> RRULE.deserialize

      assert rrule.until.time_zone == "Etc/UTC"
      assert Timex.to_erl(rrule.until) == {{1997, 7, 14}, {13, 30, 0}}
    end

    test "interval" do
      assert RRULE.deserialize("INTERVAL=1") == %RRULE{interval: 1}
    end

  end

end
