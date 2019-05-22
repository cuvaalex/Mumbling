defmodule MumblingTest do
  use ExUnit.Case, asynch: true
  use PropCheck
  doctest Mumbling
  @moduletag timeout: 10000

  describe "SimpleTest" do

    test "when string is A then result is A" do
      assert Mumbling.accum("A") == "A"
    end

    test "when string is a then result is A" do
      assert Mumbling.accum("a") == "A"
    end

    test "when string is ab then result is A-Bb" do
      assert Mumbling.accum("ab") == "A-Bb"
    end

    test "when string is AB then result is A-Bb" do
      assert Mumbling.accum("AB") == "A-Bb"
    end

  end

  describe "Property-Base" do
    property "when string is a..z then expect uppercase of a..z" do
      forall x <- choose(?a, ?z) do
        letter = <<x::utf8>>
        assert Mumbling.accum(letter)  == String.upcase(letter)
      end
    end

    property "when string is A..Z then expect uppercase of A..Z" do
      forall x <- choose(?A, ?Z) do
        letter = <<x::utf8>>
        assert Mumbling.accum(letter)  == String.upcase(letter)
      end
    end
  end

end
