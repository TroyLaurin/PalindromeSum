defmodule PalindromeSum do
  defmodule State do
    # @type t :: %{
    #   digits :: tuple(),
    #   length :: int,
    #   base :: int,
    #   x :: tuple,
    #   y :: tuple,
    #   z :: tuple,
    #   carry :: tuple
    # }

    defstruct [:digits, :length, :base, :x, :y, :z, :carry]
  end

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
end
