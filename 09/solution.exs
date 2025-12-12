points =
  File.stream!("input")
  |> Stream.map(fn x ->
    strings = String.split(String.trim(x), ",")
    [x, y] = Enum.map(strings, &String.to_integer/1)
    {x, y}
  end)
  |> Enum.to_list()

point_pairs =
  for x <- points,
      y <- points,
      x != y,
      do: {x, y}

point_pairs
|> MapSet.new()
|> Enum.map(fn x ->
  {a, b} = x
  a_x = elem(a, 0)
  b_x = elem(b, 0)

  a_y = elem(a, 1)
  b_y = elem(b, 1)

  width = abs(a_x - b_x)
  height = abs(a_y - b_y)
  (width + 1) * (height + 1)
end)
|> Enum.max()
|> IO.inspect()

# part 2 is bounds checkings but hard
defmodule Polygon do
  def generate_sorted_rectangles(coords) do
    indexed_coords = Enum.with_index(coords)

    rectangles =
      for {c1, i} <- indexed_coords,
          {c2, j} <- indexed_coords,
          i < j do
        {x1, y1} = c1
        {x2, y2} = c2

        {(abs(x2 - x1) + 1) * (abs(y2 - y1) + 1), {c1, c2}}
      end

    Enum.sort(rectangles, :desc)
  end

  def is_colliding?(coords, {{x1, y1}, {x2, y2}}) do
    x_min = min(x1, x2)
    x_max = max(x1, x2)
    y_min = min(y1, y2)
    y_max = max(y1, y2)

    polygon_edges = Enum.chunk_every(coords ++ [hd(coords)], 2, 1, :discard)

    Enum.any?(polygon_edges, fn [p1, p2] ->
      is_not_valid?(x_min, x_max, y_min, y_max, p1, p2)
    end)
  end

  defp is_not_valid?(x_min, x_max, y_min, y_max, {x1, y1}, {x2, y2}) do
    edge_x_min = min(x1, x2)
    edge_x_max = max(x1, x2)
    edge_y_min = min(y1, y2)
    edge_y_max = max(y1, y2)

    (x1 > x_min and x1 < x_max and y1 > y_min and y1 < y_max) or
      (y1 > y_min and y1 < y_max and
         edge_x_min <= x_min and x_min < edge_x_max and
         edge_x_min < x_max and x_max <= edge_x_max) or
      (x1 > x_min and x1 < x_max and
         edge_y_min <= y_min and y_min < edge_y_max and
         edge_y_min < y_max and y_max <= edge_y_max)
  end
end

area_rectangles = Polygon.generate_sorted_rectangles(points)

Enum.find(area_rectangles, fn {_, rect} -> !Polygon.is_colliding?(points, rect) end)
|> elem(0)
|> IO.inspect()
