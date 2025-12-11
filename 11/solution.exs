defmodule Search do
  def find_paths(graph, start_node, end_node) do
    recurse(graph, start_node, end_node, [start_node], MapSet.new([start_node]))
  end

  defp recurse(graph, current_node, end_node, current_path, visited_set) do
    if current_node == end_node do
      [Enum.reverse(current_path)]
    else
      neighbors = Map.get(graph, current_node, [])

      Enum.flat_map(neighbors, fn neighbor ->
        if not MapSet.member?(visited_set, neighbor) do
          new_path = [neighbor | current_path]
          new_visited_set = MapSet.put(visited_set, neighbor)

          recurse(graph, neighbor, end_node, new_path, new_visited_set)
        else
          []
        end
      end)
    end
  end
end

graph =
  File.stream!("input")
  |> Stream.map(&String.trim/1)
  |> Stream.map(fn x ->
    [key, parts] = String.split(x, ": ")
    {key, String.split(parts)}
  end)
  |> Map.new()

start_key = "you"
end_key = "out"

Search.find_paths(graph, start_key, end_key) |> Enum.count() |> IO.inspect()
