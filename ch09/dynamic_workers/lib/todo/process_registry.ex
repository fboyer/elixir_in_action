defmodule Todo.ProcessRegistry do
  use GenServer

  import Kernel, except: [send: 2]

  def start_link do
    IO.puts("Starting to-do process registry.")

    GenServer.start_link(__MODULE__, nil, name: :process_registry)
  end

  def register_name(key, pid) do
    GenServer.call(:process_registry, {:register_name, key, pid})
  end

  def unregister_name(key) do
    GenServer.call(:process_registry, {:unregister_name, key})
  end

  def send(key, message) do
    case whereis_name(key) do
      :undefined -> {:badarg, {key, message}}
      pid ->
        Kernel.send(pid, message)
        pid
    end
  end

  def whereis_name(key) do
    GenServer.call(:process_registry, {:whereis_name, key})
  end

  def init(_) do
    {:ok, Map.new()}
  end

  def handle_call({:register_name, key, pid}, _from, process_registry) do
    case Map.has_key?(process_registry, key) do
      true ->
        {:reply, :no, process_registry}
      false ->
        Process.monitor(pid)
        {:reply, :yes, Map.put(process_registry, key, pid)}
    end
  end

  def handle_call({:unregister_name, key}, _from, process_registry) do
    {:reply, key, Map.delete(process_registry, key)}
  end

  def handle_call({:whereis_name, key}, _from, process_registry) do
    {:reply, Map.get(process_registry, key, :undefined), process_registry}
  end

  def handle_info({:DOWN, _, :process, pid, _}, process_registry) do
    {:noreply, deregister_pid(process_registry, pid)}
  end

  def handle_info(_, process_registry), do: {:noreply, process_registry}

  defp deregister_pid(process_registry, pid) do
    process_registry
    |> Stream.reject(fn({_, registered_pid}) -> registered_pid == pid end)
    |> Enum.into(%{})
  end
end
