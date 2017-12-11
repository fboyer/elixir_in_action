defmodule PageCache do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: :page_cache)
  end

  def cached(key, fun) do
    GenServer.call(:page_cache, {:cached, key, fun})
  end

  def init(_) do
    {:ok, %{}}
  end

  def handle_call({:cached, key, fun}, _from, cache) do
    value = case Map.get(cache, key) do
      nil ->
        fun.()

      value ->
        value
    end

    {:reply, value, Map.put(cache, key, value)}
  end
end
