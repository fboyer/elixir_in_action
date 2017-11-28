defmodule FileHelper do
    def large_lines!(path) do
        path
        |> read_lines()
        |> Enum.filter(&(String.length(&1) > 80))
    end

    def lines_length!(path) do
        path
        |> read_lines()
        |> Stream.map(&String.length/1)
        |> Enum.into([])
    end

    def longest_line_length!(path) do
      path
      |> read_lines()
      |> Stream.map(&String.length/1)
      |> Enum.max()
    end

    def longest_line!(path) do
      path
      |> read_lines()
      |> Enum.max_by(&String.length/1) 
    end

    def words_per_line(path) do
      path
      |> read_lines()
      |> Stream.map(&String.split/1)
      |> Stream.map(&length/1)
      |> Enum.into([])
    end

    defp read_lines(path) do
      path
      |> File.stream!()
      |> Stream.map(&String.replace(&1, "\n", ""))
    end
end
