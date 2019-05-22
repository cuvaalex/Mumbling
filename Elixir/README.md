# Mumbling

Difficulty: Novice
Duration: 2h
Language: Elixir

This time no story, no theory. The examples below show you how to write function accum:

Examples:

```
accum("abcd") -> "A-Bb-Ccc-Dddd"
accum("RqaEzty") -> "R-Qq-Aaa-Eeee-Zzzzz-Tttttt-Yyyyyyy"
accum("cwAt") -> "C-Ww-Aaa-Tttt"
```
You should respect the TDD approach:

1 Write a simple failing test
2 Write enough production code to make the test green
3 Refactor the production code to respect SOLID and Clean Code principle, then run the test again
4 Refactor the test code to respect SOLID and Clean Code principle, then run the test again
5 Restart with 1.

## Resolution
Here we have nothing, so we create our project first:
```
> mix new MumblingKataElixir
```

This will create our kata project, for the moment, there is no need to add any dependencies, I like to add a mix-test-watch dependency, it’s a cool tool that runs the test after any change you make on your code. 

And we can now start the first cycle

### First Cycle
We always need to start with the most simple test we need from the input, we will then start with the input “A” and we expect to return “A”. You probably ask why we should test first the capital “A” instead of the minuscule “a”. It is because if we where testing first the minuscule “a” then we would have hidden the capital “A” case and would never know it works or not. Always start with the most simple case.
```
defmodule MumblingTest do
  use ExUnit.Case, asynch: true
  doctest Mumbling

  test "when string is A then result is A" do
    assert Mumbling.accum("A") == "A"
  end
end
```
The name of the test should always explain what intention we are trying to test, the result reader should never need to read the test content to understand what was your intention. It should be explicit.

This does not compile because the Mumbling module doesn’t exist. Now that we have a failing test (doesn’t compile) we write just enough production code to allow it to compile.

```
defmodule Mumbling do
  @moduledoc """
  Documentation for Mumbling.
  """
  def accum(text) do
    
  end
end
```

We run again and the test fails, we have to write the necessary production code to make it work.

```
defmodule Mumbling do
  @moduledoc """
  Documentation for Mumbling.
  """
  def accum(text) do
    text
  end
end
```
We just return the same text, this is known “Faking Test”.
```
mix test
.

Finished in 0.02 seconds
1 test, 0 failures
```
And now the test is green, here the refactor phase is not needed as we don’t have any duplication code, we are still in the simplicity. We can start a new cycle.

### Cycle 2
We need now to try the next simple case if I give a minuscule “a”, then I expect a capital “A” 
```
test "when string is a then result is A" do
    assert Mumbling.accum("a") == "A"
end
```
As expected if run the test, it fails and returns the same input a,  minuscule “a”; we must now implement enough production code to make our test green, but without breaking the previous one.
```
defmodule Mumbling do
  @moduledoc """
  Documentation for Mumbling.
  """
  def accum(text) do
    "A"
  end
end
```
And now the test is green, here again, the refactor phase is not needed as we don’t have any duplication code. We can start a new cycle

### Cycle 3
We write now a failing test for the letter “B”, as we did for the letter “A”, we see it fail, we can now implement properly the production code so any letter would work.
```
defmodule Mumbling do
  @moduledoc """
  Documentation for Mumbling.
  """
  def accum(text) do
    String.upcase "a"
  end
end
```
But finally, we have duplicate code in our test code that must be refactored, so we make it easy to read for the reader. As you understand the refactoring phase is not only for the production code but also for the testing code.

One thing very important here:

 we must never refactor the production code at the same time that the test code

This is really important, the test or the production code is there to show you if you broke something, in either part.

### Refactoring
We identified a code test duplication, we should refactor, at the same time we could validate for any letters.

As we said our reader should understand our intention, we should have written a test call “when the string is any capital letter A…Z then result should be the same”.  To simplify this kind of test I use Property-Base testing or know also as QuickCheck, it’s a new kind of test, introduced with QuickCheck in Haskel. To do so you can use Propcheck dependency
```
 {:propcheck, "~> 1.1", only: [:test, :dev]}
```
And refactor the following test
```
defmodule MumblingTest do
  use ExUnit.Case, asynch: true
  use PropCheck
  doctest Mumbling
  
  property "when string is a..z then expect uppercase of a..z" do
    forall x <- choose(?a, ?z) do
      letter = <<x::utf8>>
      assert Mumbling.accum(letter) == String.upcase(letter)
    end
  end

  property "when string is A..Z then expect A..Z" do
    forall x <- choose(?A, ?Z) do
      letter = <<x::utf8>>
      assert Mumbling.accum(letter) == String.upcase(letter)
    end
  end
end
```
Propcheck will use a controlled random system that will try to find a failing case, with this two tests, we have better coverage of our previous two tests who tested only the letter “A” cases. 

### Cycle 4
We can now start our 4th case, where we test the case we have two characters “ab” and we expect to return “A-Bb”.
```
defmodule MumblingTest do
  use ExUnit.Case, asynch: true
  use PropCheck
  doctest Mumbling
  
  ...
  
  test "when string is ab then result is A-Bb" do
    assert Mumbling.accum("ab") == "A-Bb"
  end
 ```
Our production code was implemented to support only one character, we must now improve it as follow
```
defmodule Mumbling do
  @moduledoc """
  Documentation for Mumbling.
  """
  require Logger

  def accum(text) do
    Logger.debug "start accum/1 with #{text}"
    if String.length(text) > 1 do
      accum(String.graphemes(text), 1)
    else
      String.upcase(text)
    end
  end

  def accum(list, size)  do
    Logger.debug "start accum/2 with #{inspect(list)}"
    [head | tail] = list
    if length(tail) > 0 do
      String.pad_trailing(accum(head), size, head) <> "-" <> accum(tail, size+1)
    else
      String.pad_trailing(accum(head), size, head)
    end
  end
end
```
### Cycle 5
We need now make a last test to validate our case is the one when we give uppercase into the string, e.g “AB” we expect “A-Bb”
```
   test "when string is AB then result is A-Bb" do
      assert Mumbling.accum("AB") == "A-Bb"
    end
```
As expected we have a failure
```
  1) test SimpleTest when string is AB then result is A-Bb (MumblingTest)
     test/mumbling_test.exs:21
     Assertion with == failed
     code:  assert Mumbling.accum("AB") == "A-Bb"
     left:  "A-BB"
     right: "A-Bb"
     stacktrace:
       test/mumbling_test.exs:22: (test)

.

Finished in 0.05 seconds
2 properties, 4 tests, 1 failure, 2 excluded
```
we implement the product code
```
defmodule Mumbling do
  @moduledoc """
  Documentation for Mumbling.
  """
  require Logger

  def accum(text) do
    Logger.debug "start accum/1 with #{text}"
    if String.length(text) > 1 do
      accum(String.graphemes(text), 1)
    else
      String.upcase(text)
    end
  end

  def accum(list, size)  do
    Logger.debug "start accum/2 with #{inspect(list)}"
    [head | tail] = list
    if length(tail) > 0 do
      String.pad_trailing(accum(head), size, String.downcase(head)) 
        <> "-" 
        <> accum(tail, size+1)
    else
      String.pad_trailing(accum(head), size, String.downcase(head))
    end
  end
end
```
Voilà it’s done, we need to do the last refactoring, to improve the quality of the code and we will be done
```
defmodule Mumbling do
  @moduledoc """
  Documentation for Mumbling.
  """
  require Logger
  
  def accum(text) do
    text
    |> String.graphemes
    |> Enum.with_index
    |> Enum.map(&serialize/1)
    |> Enum.join("-")
  end
  
  def serialize({letter, index}) do
    letter
    |> String.duplicate(index+1)
    |> String.capitalize
  end
end
```
The kata is done
