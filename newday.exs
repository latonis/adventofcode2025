args = System.argv()

IO.puts("Arguments given: #{args}")

day = String.to_integer(hd(args))

day_str = String.pad_leading(Integer.to_string(day), 2, "0")

IO.puts("Starting Day #{day_str}...")

File.mkdir(day_str)

files = ["test", "input", "solution.exs"]

creation_function = fn x -> File.touch("#{day_str}/#{x}") end

Enum.map(files, creation_function)
