# PalindromeSum

Every positive integer is a sum of three palindromes.
https://arxiv.org/pdf/1602.06208.pdf

An implementation of the algorithm in Elixir

## Usage

```
> iex -S mix
Compiling 2 files (.ex)
Interactive Elixir (1.6.6) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> import PalindromeSum
PalindromeSum
iex(2)> "1234" |> parse(10) |> solve |> dump |> verify
1234
----
1001
 232
   1
----
1234
:ok
```

The algorithm also works in bases other than 10!
```
> iex -S mix
Interactive Elixir (1.6.6) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> import PalindromeSum
PalindromeSum
iex(2)> "CAFE" |> parse(16) |> solve |> dump |> verify
CAFE
----
C00C
 AEA
   8
----
CAFE
:ok
```

