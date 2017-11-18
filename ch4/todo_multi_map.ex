defmodule TodoMultiMap do
  
  def new(), do: Map.new()

  def add(map, key, value) do
    Map.update(
      map,
      key,
      [value],
      &[value | &1]
    )
  end

  def get(map, key) do
    Map.get(map, key, [])
  end
end
