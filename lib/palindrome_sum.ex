defmodule PalindromeSum do
  @moduledoc """
  An implementation of the algorithm at https://arxiv.org/pdf/1602.06208.pdf, in Elixir
  """
  defmodule State do
    defstruct [:digits, :base, :x, :y, :z]
  end

  alias PalindromeSum.State
  import TupleMath

  def parse(input, base) do
    digits = input |> String.to_integer(base) |> get_digits(base, []) |> List.to_tuple()
    struct(PalindromeSum.State, digits: digits, length: tuple_size(digits), base: base)
  end

  def get_digits(0, _, _), do: [0]
  def get_digits(x, base, acc) when x < base, do: [x | acc]

  def get_digits(x, base, acc) do
    quotient = div(x, base)
    remainder = rem(x, base)
    get_digits(quotient, base, [remainder | acc])
  end

  def solve(%State{digits: {d1, d0}, base: g} = state) do
    cond do
      d1 <= d0 ->
        %{state | x: {d1, d1}, y: {0, d0 - d1}, z: nil}

      d1 > d0 + 1 ->
        %{state | x: {d1 - 1, d1 - 1}, y: {0, g + d0 - d1 + 1}, z: nil}

      {d1, d0} == {1, 0} ->
        %{state | x: {0, g - 1}, y: {0, 1}, z: nil}

      d1 == d0 + 1 ->
        %{state | x: {d0, d0}, y: {0, g - 1}, z: {0, 1}}
    end
  end

  def solve(%State{digits: {d2, d1, d0}, base: g} = state) do
    cond do
      d2 <= d0 ->
        %{state | x: {d2, d1, d2}, y: {0, 0, d0 - d2}, z: nil}

      d2 >= d0 + 1 and d1 != 0 ->
        %{state | x: {d2, d1 - 1, d2}, y: {0, 0, g + d0 - d2}, z: nil}

      d2 >= d0 + 1 and d1 == 0 and rem(d2 - d0 - 1, g) != 0 ->
        %{state | x: {d2 - 1, g - 1, d2 - 1}, y: {0, 0, g + d0 - d2 + 1}, z: nil}

      # else  d0 ≡ d2 − 1 (mod g)
      d2 >= 3 ->
        %{state | x: {d2 - 2, g - 1, d2 - 2}, y: {1, 1, 1}, z: nil}

      d2 == 2 ->
        %{state | x: {1, 0, 1}, y: {0, g - 1, g - 1}, z: {0, 0, 1}}

      d2 == 1 ->
        %{state | x: {0, g - 1, g - 1}, y: {0, 0, 1}, z: nil}
    end
  end

  def solve(%State{digits: {d3, d2, d1, d0}, base: g} = state) do
    case sub({d3, d2, d1, d0}, {d3, 0, 0, d3}, g) do
      {0, 2, 0, 1} when d3 == 1 ->
        # 1 2 0 2
        %{state | x: {1, 1, 1, 1}, y: {0, 0, g - 2, g - 2}, z: {0, 0, 0, 3}}

      {0, 2, 0, 1} when d3 == g - 1 ->
        # g-1 2 1 0
        %{state | x: {g - 1, 1, 1, g - 1}, y: {0, 0, g - 2, g - 2}, z: {0, 0, 0, 3}}

      {0, 2, 0, 1} ->
        # d3, 2, 0, d3+1
        %{state | x: {d3 - 1, g - 1, g - 1, d3 - 1}, y: {0, 2, 1, 2}, z: nil}

      {0, 0, m1, m0} when m1 == m0 + 1 and m0 > 0 and d3 == 1 ->
        # 1, 0, m0+1, m0+1
        %{state | x: {0, g - 1, g - 1, g - 1}, y: {0, 0, m0 + 1, m0 + 1}, z: {0, 0, 0, 1}}

      {0, 0, m1, m0} when m1 == m0 + 1 and m0 > 0 ->
        # d3, 0, m0+1, d0
        %{state | x: {d3 - 1, g - 2, g - 2, d3 - 1}, y: {0, 1, 3, 1}, z: {0, 0, m0, m0}}

      {0, m2, m1, m0} ->
        # d3 0 0 d3 + p1 + p2
        %{x: {x2, x1, x0}, y: {y2, y1, y0}, z: nil} = solve(%State{digits: {m2, m1, m0}, base: g})
        %{state | x: {d3, 0, 0, d3}, y: {0, x2, x1, x0}, z: {0, y2, y1, y0}}

      _ ->
        if {d3, d2, d1, d0} == {1, 0, 0, 0} do
          %{state | x: {0, g - 1, g - 1, g - 1}, y: {0, 0, 0, 1}, z: nil}
        else
          %{state | x: {d3 - 1, g - 1, g - 1, d3 - 1}, y: {0, 0, 0, g + d0 - d3}, z: {0, 0, 0, 1}}
        end
    end
  end

  def verify(state) do
    sum = add(state.x, add(state.y, state.z, state.base), state.base)
    if sum == state.digits, do: :ok, else: :error
  end

  def dump(state) do
    IO.puts(pretty(state.digits, state.base))
    IO.puts(line(state.digits))
    if state.x, do: IO.puts(pretty(state.x, state.base))
    if state.y, do: IO.puts(pretty(state.y, state.base))
    if state.z, do: IO.puts(pretty(state.z, state.base))

    add(state.x, add(state.y, state.z, state.base), state.base)
    |> case do
      nil ->
        :ok

      sum ->
        IO.puts(line(state.digits))
        IO.puts(pretty(sum, state.base))
    end

    state
  end

  defp pretty(digits, base) do
    digits
    |> Tuple.to_list()
    |> Enum.map(&Integer.to_string(&1, base))
    |> Enum.join()
    |> String.replace_leading("0", " ")
  end

  defp line(digits) do
    digits
    |> Tuple.to_list()
    |> Enum.map(fn _ -> "-" end)
    |> Enum.join()
  end
end

#         %{state | x: {}, y: {}, z: {}}
