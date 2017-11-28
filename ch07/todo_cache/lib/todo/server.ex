defmodule Todo.Server do
  use GenServer

  def start() do
    GenServer.start(__MODULE__, :ok)
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

  def init(_) do
    {:ok, Todo.List.new()}
  end

  def handle_cast({:add_entry, new_entry}, state) do
    {:noreply, Todo.List.add_entry(state, new_entry)}
  end

  def handle_cast({:update_entry, entry_id, updater_fun}, state) do
    {:noreply, Todo.List.update_entry(state, entry_id, updater_fun)}
  end

  def handle_cast({:update_entry, new_entry}, state) do
    {:noreply, Todo.List.update_entry(state, new_entry)}
  end

  def handle_cast({:delete_entry, entry_id}, state) do
    {:noreply, Todo.List.delete_entry(state, entry_id)}
  end

  def handle_call({:entries, date}, _from, state) do
    {:reply, Todo.List.entries(state, date), state}
  end
end
