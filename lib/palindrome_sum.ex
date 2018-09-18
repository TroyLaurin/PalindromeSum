defmodule PalindromeSum do
  @moduledoc """
  An implementation of the algorithm at https://arxiv.org/pdf/1602.06208.pdf, in Elixir
  """
  defmodule State do
    defstruct [:digits, :base, :x, :y, :z]
  end

  alias PalindromeSum.State

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

      d1 == d0 + 1 ->
        %{state | x: {d0, d0}, y: {0, g - 1}, z: {0, 1}}
    end
  end

  def solve(%State{digits: {d2, d1, d0}, base: g} = state) do
    cond do
      d2 <= d0 ->
        %{state | x: {d2, d1, d2}, y: {0, 0, d0 - d2}, z: nil}

      d2 >= d1 + 1 and d1 != 0 ->
        %{state | x: {d2, d1 - 1, d2}, y: {0, 0, g + d0 - d2}, z: nil}

      d2 >= d1 + 1 and d1 == 0 and rem(d2 - d0 - 1, g) != 0 ->
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
end

#         %{state | x: {}, y: {}, z: {}}
