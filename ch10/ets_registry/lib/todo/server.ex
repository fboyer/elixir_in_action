defmodule Todo.Server do
  use GenServer

  def start_link(name) do
    IO.puts("Starting to-do server for #{name}.")

    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  def add_entry(pid, new_entry) do
    GenServer.cast(pid, {:add_entry, new_entry})
  end

  def update_entry(pid, entry_id, updater_fun) do
    GenServer.cast(pid, {:update_entry, entry_id, updater_fun})
  end

  def update_entry(pid, new_entry) do
    GenServer.cast(pid, {:update_entry, new_entry})
  end

  def delete_entry(pid, entry_id) do
    GenServer.cast(pid, {:delete_entry, entry_id})
  end

  def entries(pid, date) do
    GenServer.call(pid, {:entries, date})
  end

  def whereis(name) do
    Todo.ProcessRegistry.whereis_name({:todo_server, name})
  end

  def init(name) do
    {:ok, {name, Todo.Database.get(name) || Todo.List.new()}}
  end

  def handle_cast({:add_entry, new_entry}, {name, todo_list}) do
    new_todo_list = Todo.List.add_entry(todo_list, new_entry)
    Todo.Database.store(name, new_todo_list)

    {:noreply, {name, new_todo_list}}
  end

  def handle_cast({:update_entry, entry_id, updater_fun}, {name, todo_list}) do
    new_todo_list = Todo.List.update_entry(todo_list, entry_id, updater_fun)
    Todo.Database.store(name, new_todo_list)

    {:noreply, {name, new_todo_list}}
  end

  def handle_cast({:update_entry, new_entry}, {name, todo_list}) do
    new_todo_list = Todo.List.update_entry(todo_list, new_entry)
    Todo.Database.store(name, new_todo_list)

    {:noreply, {name, new_todo_list}}
  end

  def handle_cast({:delete_entry, entry_id}, {name, todo_list}) do
    new_todo_list = Todo.List.delete_entry(todo_list, entry_id)
    Todo.Database.store(name, new_todo_list)

    {:noreply, {name, new_todo_list}}
  end

  def handle_call({:entries, date}, _from, {_name, todo_list} = state) do
    {:reply, Todo.List.entries(todo_list, date), state}
  end

  defp via_tuple(name) do
    {:via, Todo.ProcessRegistry, {:todo_server, name}}
  end
end
