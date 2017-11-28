defmodule TodoList do

  def new(), do: TodoMultiMap.new()

  def add_entry(todo_list, entry) do
    TodoMultiMap.add(todo_list, entry.date, entry)
  end

  def entries(todo_list, date) do
    TodoMultiMap.get(todo_list, date)
  end
end
