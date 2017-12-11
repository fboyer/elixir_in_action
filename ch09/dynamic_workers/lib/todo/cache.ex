defmodule Todo.Cache do
  use GenServer

  def start_link() do
    IO.puts("Starting to-do cache.")

    GenServer.start_link(__MODULE__, :ok, name: :todo_cache)
  end

  def server_process(todo_list_name) do
    case Todo.ProcessRegistry.whereis_name({:todo_server, todo_list_name}) do
      :undefined ->
        GenServer.call(:todo_cache, {:server_process, todo_list_name})
      pid ->
        pid
    end
  end

  def init(_) do
    {:ok, []}
  end

  def handle_call({:server_process, todo_list_name}, _from, state) do
    case Todo.ProcessRegistry.whereis_name({:todo_server, todo_list_name}) do
      :undefined ->
        {:ok, new_server} = Todo.ServerSupervisor.start_child(todo_list_name)

        {:reply, new_server, state}
      todo_server ->
        {:reply, todo_server, state}
    end
  end
end
