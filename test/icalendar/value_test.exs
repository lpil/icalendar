defmodule ICalendar.ValueTest do
  use ExUnit.Case

  alias ICalendar.Value

  test "value of a datetime tuple" do
    result = Value.to_ics({{2016, 1, 4}, {0, 42, 23}})
    assert result == "20160104T004223"
  end

  test "value of some other tuple" do
    result = Value.to_ics({{2016, 13, 4}, {0, 42, 23}})
    assert result == {{2016, 13, 4}, {0, 42, 23}}
  end
end
