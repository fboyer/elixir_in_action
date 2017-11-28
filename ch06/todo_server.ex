defmodule TodoServer do
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
    {:ok, TodoList.new()}
  end

  def handle_cast({:add_entry, new_entry}, state) do
    {:noreply, TodoList.add_entry(state, new_entry)}
  end

  def handle_cast({:update_entry, entry_id, updater_fun}, state) do
    {:noreply, TodoList.update_entry(state, entry_id, updater_fun)}
  end

  def handle_cast({:update_entry, new_entry}, state) do
    {:noreply, TodoList.update_entry(state, new_entry)}
  end

  def handle_cast({:delete_entry, entry_id}, state) do
    {:noreply, TodoList.delete_entry(state, entry_id)}
  end

  def handle_call({:entries, date}, _from, state) do
    {:reply, TodoList.entries(state, date), state}
  end
end

defmodule TodoList do
  defstruct [auto_id: 1, entries: Map.new()]

  def new, do: %TodoList{}

  def new(entries) do
    Enum.reduce(
      entries,
      %TodoList{},
      &add_entry(&2, &1)
    )
  end

  def add_entry(%{auto_id: auto_id, entries: entries} = todo_list, entry) do
    entry = Map.put(entry, :id, auto_id)

    new_entries = Map.put(entries, auto_id, entry)

    %TodoList{todo_list | auto_id: auto_id + 1, entries: new_entries}
  end

  def entries(%TodoList{entries: entries}, date) do
    entries
    |> Stream.filter(fn({_, entry}) ->
      entry.date == date
    end)
    |> Enum.map(fn({_, entry}) ->
      entry
    end)
  end

  def update_entry(%TodoList{entries: entries} = todo_list, entry_id, updater_fun) do
    case entries[entry_id] do
      nil ->
        todo_list
      old_entry ->
        old_entry_id = old_entry.id
        new_entry = %{id: ^old_entry_id} = updater_fun.(old_entry)
        new_entries = Map.put(entries, new_entry.id, new_entry)
        %TodoList{todo_list | entries: new_entries}
    end
  end

  def update_entry(todo_list, %{} = new_entry) do
    update_entry(todo_list, new_entry.id, fn(_) -> new_entry end)
  end

  def delete_entry(%TodoList{entries: entries} = todo_list, entry_id) do
    new_entries = Map.delete(entries, entry_id)
    %TodoList{todo_list | entries: new_entries}
  end
end
