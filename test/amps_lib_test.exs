defmodule AmpsLibTest do
  use ExUnit.Case
  doctest AmpsLib

  test "greets the world" do
    assert AmpsLib.hello() == :world
  end
end
