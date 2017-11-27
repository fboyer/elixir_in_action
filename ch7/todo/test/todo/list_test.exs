defmodule Todo.ListTest do
  use ExUnit.Case

  test "new/0 returns an empty %Todo.List{}" do
    assert Todo.List.new() == %Todo.List{}
  end

  test "new/1 returns a %Todo.List{} with the entries passed as a parameter" do
    entries = [
      %{date: {2013, 12, 19}, title: "Dentist"},
      %{date: {2013, 12, 20}, title: "Shopping"},
      %{date: {2013, 12, 19}, title: "Movies"}
    ]

    assert Todo.List.new(entries) == Enum.reduce(entries, %Todo.List{}, &Todo.List.add_entry(&2, &1))
  end
end
