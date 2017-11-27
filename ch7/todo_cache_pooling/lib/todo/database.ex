defmodule Todo.Database do
  use GenServer

  def start(db_folder) do
    GenServer.start(__MODULE__, db_folder, name: :database_server)
  end

  def store(key, data) do
    key
    |> get_worker
    |> Todo.DatabaseWorker.store(key, data)
  end

  def get(key) do
    key
    |> get_worker
    |> Todo.DatabaseWorker.get(key)
  end

  def get_worker(key) do
    GenServer.call(:database_server, {:get_worker, key})
  end

  def init(db_folder) do
    {:ok, start_workers(3, db_folder)}
  end

  def handle_call({:get_worker, key}, _from, workers) do
    worker_key = :erlang.phash2(key, Map.size(workers))
    {:reply, workers[worker_key], workers}
  end

  defp start_workers(num_workers, db_folder) do
    for index <- 1..num_workers, into: Map.new() do
      {:ok, pid} = Todo.DatabaseWorker.start(db_folder)
      {index - 1, pid}
    end
  end
end
