## Elixir Generator

This plugin adds a command to easily add more modules to your `Mix` project.
Just like Mix, it creates a lib and a test file for you to start coding.

#### Self-generate modules and unit tests

Hit `:EX` and vim will prompt you to include the path of your new module:

```Type the path (e.g store/cart/item):```

if you type `shopping/cart`, it will generate two files:

* `lib/shopping/cart.ex`

```elixir
defmodule Store.Cart do
  @moduledoc """
  Some Module main doc..
  """

  @doc """
  Some method behavior.

  ## Examples

    iex> Store.Cart.some_methot([])
    {:ok}

  """
  def some_method(opts \\ [])

  def some_method(opts) when opts == [] do
    {:ok}
  end

  def some_method(opts) do
    {:ok, [opts]}
  end

  defp private_method do
    {:ok}
  end
end
```

* `test/shopping/cart_test.exs`

```elixir
defmodule Shopping.CartTest do
  use Store.DataCase
  alias Shopping.Cart

  describe "some_method/0" do
    test "some method without param" do"
      assert Cart.some_method == {:ok}
    end
  end

  describe "some_method/1" do
    test "some method with param" do"
      assert Cart.some_method(1) == {:ok, [1]}
    end
  end
end
```

You may wanna use [vim.test](https://github.com/vim-test/vim-test)
to run your test with a key mapping. If offers a large amount supported languages.

#### Contributing
Please consider contributing back.
