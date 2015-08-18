##Elixir Generator

This plugin adds a command to easely add more modules to your `Mix` projetc.
Just like Mix creates a lib and a test file for you to start coding.

####Self-generate modules and unit tests

Hit `:EX` and vim will prompt you to include the path of your new module:

```Type the path (e.g store/cart/item):```

if you type `store/special_cart`, it will generate two files:

* `lib/store/special_cart.ex`

```
defmodule Store.SpecialCart do

end
```

* `test/store/special_cart_test.exs`

```
Code.require_file "../test_helper.exs", __DIR__

defmodule Store.SpecialCartTest do
  use ExUnit.Case, async: true
  require Store.SpecialCart, as: C

  test "some method" do
    assert C.some_method == true
  end
end
```
