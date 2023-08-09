defmodule ParseTr31KeyblockFormatTest do
  use ExUnit.Case

  test "form a TR-31 format" do
    # TR-31 consist of:
    #  a) 1 byte version - must be A, B or C
    #  b) 4 byte key block length - must be numeric, the length everything including a)
    #  c) 2 byte key usage - must be D0, M0, M1, M2, M3, M4, M5, P0
    #  d) 1 byte algorithm - must be A, D, E, H, R, S, or T
    #  e) 1 byte mode of use - must be B, C, D, E, G, N, S, V, X
    #  f) 2 byte key version number - can be alphanumeric
    #  g) 1 byte exportability - must be E, N, or S
    #  h) 2 byte number of optional blocks - must be numeric
    #  i) 2 byte reserved - can be alphanumeric
    #  j) 2 byte size indicator for the encrypted key data
    #  k) variable length encrypted key data
    #  l) 8 byte mac

    ver = ~w(A B C) |> Enum.random
    key_usage = ~w(D0 M0 M1 M2 M3 M4 M5 P0) |> Enum.random
    algorithm = ~w(A D E H R S T) |> Enum.random
    mode_of_use = ~w(B C D E G N S V X) |> Enum.random
    version_number = "00"
    exportibility = ~w(E N S) |> Enum.random
    optional_blocks = "00"
    reserved = "00"

    key_length = :rand.uniform(36) # 72 is the max key length (I think in ascii hex)
    key_value = :crypto.strong_rand_bytes(key_length) |> Base.encode16
    key_length = key_length |> to_string

    mac = :crypto.strong_rand_bytes(4) |> Base.encode16

    key_usage_till_mac =
      key_usage <> algorithm <> mode_of_use <> version_number
      <> exportibility <> optional_blocks <> reserved <> key_length <> key_value <> mac

    key_block_length = 1 + String.length(key_usage_till_mac) |> to_string |> String.pad_leading(4, "0")

    entire_key_block = ver <> key_block_length <> key_usage_till_mac

  end

  test "parse a TR-31 format" do
    # TR-31 consist of:
    #  a) 1 byte version - must be A, B or C
    #  b) 4 byte key block length - must be numeric, the length everything including a)
    #  c) 2 byte key usage - must be D0, M0, M1, M2, M3, M4, M5, P0
    #  d) 1 byte algorithm - must be A, D, E, H, R, S, or T
    #  e) 1 byte mode of use - must be B, C, D, E, G, N, S, V, X
    #  f) 2 byte key version number - can be alphanumeric
    #  g) 1 byte exportability - must be E, N, or S
    #  h) 2 byte number of optional blocks - must be numeric
    #  i) 2 byte reserved - can be alphanumeric
    #  j) 2 byte size indicator for the encrypted key data
    #  k) variable length encrypted key data
    #  l) 8 byte mac

    ver = ~w(A B C) |> Enum.random
    key_usage = ~w(D0 M0 M1 M2 M3 M4 M5 P0) |> Enum.random
    algorithm = ~w(A D E H R S T) |> Enum.random
    mode_of_use = ~w(B C D E G N S V X) |> Enum.random
    version_number = "00"
    exportibility = ~w(E N S) |> Enum.random
    optional_blocks = "00"
    reserved = "00"

    key_length = :rand.uniform(36) # 72 is the max key length (I think in ascii hex)
    key_value = :crypto.strong_rand_bytes(key_length) |> Base.encode16
    key_length = key_length |> to_string

    mac = :crypto.strong_rand_bytes(4) |> Base.encode16

    key_usage_till_mac =
      key_usage <> algorithm <> mode_of_use <> version_number
      <> exportibility <> optional_blocks <> reserved <> key_length <> key_value <> mac

    key_block_length = 1 + String.length(key_usage_till_mac) |> to_string |> String.pad_leading(4, "0")

    entire_key_block = ver <> key_block_length <> key_usage_till_mac

    {ver, the_rest} = match_ver(entire_key_block)
    IO.inspect ver
    {block_length, the_rest} = match_block_length(the_rest)
    IO.inspect block_length
    {key_usage, the_rest} = match_key_usage(the_rest)
    IO.inspect key_usage

  end

  def match_ver(<<version::binary-size(1), the_rest::binary>>) when version in ~w(A B C) do
    {version, the_rest}
  end

  def match_block_length(<<_::4, a::4, _::4, b::4, _::4, c::4, _::4, d::4, the_rest::binary>>) do
    {a*1000 + b*100 + c*10 + d, the_rest}
  end

  def match_key_usage(<<key_usage::binary-size(2), the_rest::binary>>) when key_usage in ~w(D0 M0 M1 M2 M3 M4 M5 P0) do
    {key_usage, the_rest}
  end

  def match_algorithm(<<algorithm::binary-size(1), the_rest::binary>>) when algorithm in ~w(A D E H R S T) do
    {algorithm, the_rest}
  end

  def match_mode_of_use(<<mode_of_use::binary-size(1), the_rest::binary>>) when mode_of_use in ~w(B C D E G N S V X) do
    {mode_of_use, the_rest}
  end

  def match_version_number(<<version_number::binary-size(2), the_rest::binary>>) do
    {version_number, the_rest}
  end

  def match_exportibility(<<exportibility::binary-size(2), the_rest::binary>>) do
    {exportibility, the_rest}
  end

  def match_optional_blocks(<<optional_blocks::binary-size(2), the_rest::binary>>) do
    {optional_blocks, the_rest}
  end

  def match_reserved(<<reserved::binary-size(2), the_rest::binary>>) do
    {reserved, the_rest}
  end

  def match_key_length(<<_::4, a::4, _::4, b::4, the_rest::binary>>) do
    {a*10+b, the_rest}
  end

  def match_key(key_size, data) do
    <<key::binary-size(key_size), the_rest::binary>> = data
    {key, the_rest}
  end

  def match_mac(<<mac::binary-size(4), the_rest::binary>>) do
    {mac, the_rest}
  end

end
