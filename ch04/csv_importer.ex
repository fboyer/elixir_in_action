defmodule TodoList.CSVImporter do
  def import(path) do
    path
    |> File.stream!()
    |> Stream.map(&String.replace(&1, "\n", ""))
    |> Stream.map(&create_entry_map(&1))
    |> TodoList.new()
  end

  def create_entry_map(entry) do
      entry
      |> String.split(",")
      |> parse_entry()
  end

  def parse_entry([date, title | []]) do
    parsed_date =
      date
      |> String.split("/")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()

    %{date: parsed_date, title: title}
  end
end
