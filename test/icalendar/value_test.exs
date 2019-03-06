defmodule ICalendar.ValueTest do
  use ExUnit.Case

  alias ICalendar.Value

  test "value of a date" do
    result = Value.to_ics(Timex.to_date({2016, 1, 4}))
    assert result == "20160104"
  end

  test "value of a datetime" do
    result = Value.to_ics(Timex.to_datetime({{2016, 1, 4}, {0, 42, 23}}))
    assert result == "20160104T004223"
  end

  test "value of a datetime tuple" do
    result = Value.to_ics({{2016, 1, 4}, {0, 42, 23}})
    assert result == "20160104T004223"
  end

  test "value of a nearly datetime tuple" do
    result = Value.to_ics({{2016, 13, 4}, {0, 42, 23}})
    assert result == {{2016, 13, 4}, {0, 42, 23}}
  end

  test "value of a very different tupe" do
    result = Value.to_ics({:ok, "Hi there"})
    assert result == {:ok, "Hi there"}
  end

  test "value of a string with newline" do
    result =
      Value.to_ics("""
      Hello
      World!
      """)

    assert result == ~S"Hello\nWorld!\n"
  end

  test "value of a string with newline like chars" do
    result = Value.to_ics(~S"Hi\nthere")
    assert result == ~S"Hi\\nthere"
  end
end
