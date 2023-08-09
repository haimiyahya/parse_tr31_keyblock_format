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
    key_length = key_length |> to_string|> String.pad_leading(2, "0")

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
    # IO.inspect "key_length: #{key_length*2}"
    key = :crypto.strong_rand_bytes(key_length) |> Base.encode16
    key_length = key_length*2 |> to_string |> String.pad_leading(2, "0")

    mac = :crypto.strong_rand_bytes(4) |> Base.encode16

    key_usage_till_mac =
      key_usage <> algorithm <> mode_of_use <> version_number
      <> exportibility <> optional_blocks <> reserved <> key_length <> key <> mac

    block_length = 1 + String.length(key_usage_till_mac) |> to_string |> String.pad_leading(4, "0")

    entire_key_block = ver <> block_length <> key_usage_till_mac

    # IO.inspect entire_key_block

    # {p_ver, the_rest} = match_ver(entire_key_block)
    # # IO.inspect "ver: #{p_ver}"
    # {p_block_length, the_rest} = match_block_length(the_rest)
    # # IO.inspect "block_length: #{p_block_length}"
    # {p_key_usage, the_rest} = match_key_usage(the_rest)
    # # IO.inspect "key_usage: #{p_key_usage}"
    # {p_algorithm, the_rest} = match_algorithm(the_rest)
    # # IO.inspect "algorithm: #{p_algorithm}"
    # {p_mode_of_use, the_rest} = match_mode_of_use(the_rest)
    # # IO.inspect "mode_of_use: #{p_mode_of_use}"
    # {p_version_number, the_rest} = match_version_number(the_rest)
    # # IO.inspect "version_number: #{p_version_number}"
    # {p_exportibility, the_rest} = match_exportibility(the_rest)
    # # IO.inspect "exportibility: #{p_exportibility}"
    # {p_optional_blocks, the_rest} = match_optional_blocks(the_rest)
    # # IO.inspect "optional_blocks: #{p_optional_blocks}"
    # {p_reserved, the_rest} = match_reserved(the_rest)
    # # IO.inspect "reserved: #{p_reserved}"
    # {p_key_length, the_rest} = match_key_length(the_rest)
    # # IO.inspect "key_length: #{p_key_length}"
    # {p_key, the_rest} = match_key(p_key_length, the_rest)
    # # IO.inspect "key: #{p_key}"
    # {p_mac, the_rest} = match_mac(the_rest)
    # # IO.inspect "mac: #{p_mac}"
    result = ParseTr31KeyblockFormat.parse(entire_key_block)

    # IO.inspect result

    p_ver = Keyword.get(result, :ver)
    p_block_length = Keyword.get(result, :block_length)
    p_key_usage = Keyword.get(result, :key_usage)
    p_algorithm = Keyword.get(result, :algorithm)
    p_mode_of_use = Keyword.get(result, :mode_of_use)
    p_version_number = Keyword.get(result, :version_number)
    p_exportibility = Keyword.get(result, :exportibility)
    p_optional_blocks = Keyword.get(result, :optional_blocks)
    p_reserved = Keyword.get(result, :reserved)
    p_key_length = Keyword.get(result, :key_length)
    p_key = Keyword.get(result, :key)
    p_mac = Keyword.get(result, :mac)

    assert Enum.member?(~w(A B C), p_ver)
    assert Enum.member?(~w(D0 M0 M1 M2 M3 M4 M5 P0), p_key_usage)
    assert Enum.member?(~w(A D E H R S T), p_algorithm)
    assert Enum.member?(~w(B C D E G N S V X), p_mode_of_use)
    assert Enum.member?(~w(E N S), p_exportibility)

    assert p_ver == ver
    {block_length, _} = Integer.parse(block_length)
    assert p_block_length == block_length
    assert p_key_usage == key_usage
    assert p_algorithm == algorithm
    assert p_mode_of_use == mode_of_use
    assert p_version_number == version_number
    assert p_exportibility == exportibility
    assert p_optional_blocks == optional_blocks
    assert p_reserved == reserved
    {key_length, _} = Integer.parse(key_length)
    assert p_key_length == key_length
    assert p_key == key
    assert p_mac == mac

  end



end
