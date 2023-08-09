defmodule ParseTr31KeyblockFormat do
  @moduledoc """
  Documentation for `ParseTr31KeyblockFormat`.
  """

  def parse(entire_key_block) do

    result = []

    {p_ver, the_rest} = match_ver(entire_key_block)
    # IO.inspect "ver: #{p_ver}"
    result = Keyword.put(result, :ver, p_ver)

    {p_block_length, the_rest} = match_block_length(the_rest)
    # IO.inspect "block_length: #{p_block_length}"
    result = Keyword.put(result, :block_length, p_block_length)

    {p_key_usage, the_rest} = match_key_usage(the_rest)
    # IO.inspect "key_usage: #{p_key_usage}"
    result = Keyword.put(result, :key_usage, p_key_usage)

    {p_algorithm, the_rest} = match_algorithm(the_rest)
    # IO.inspect "algorithm: #{p_algorithm}"
    result = Keyword.put(result, :algorithm, p_algorithm)

    {p_mode_of_use, the_rest} = match_mode_of_use(the_rest)
    # IO.inspect "mode_of_use: #{p_mode_of_use}"
    result = Keyword.put(result, :mode_of_use, p_mode_of_use)

    {p_version_number, the_rest} = match_version_number(the_rest)
    # IO.inspect "version_number: #{p_version_number}"
    result = Keyword.put(result, :version_number, p_version_number)

    {p_exportibility, the_rest} = match_exportibility(the_rest)
    # IO.inspect "exportibility: #{p_exportibility}"
    result = Keyword.put(result, :exportibility, p_exportibility)

    {p_optional_blocks, the_rest} = match_optional_blocks(the_rest)
    # IO.inspect "optional_blocks: #{p_optional_blocks}"
    result = Keyword.put(result, :optional_blocks, p_optional_blocks)

    {p_reserved, the_rest} = match_reserved(the_rest)
    # IO.inspect "reserved: #{p_reserved}"
    result = Keyword.put(result, :reserved, p_reserved)

    {p_key_length, the_rest} = match_key_length(the_rest)
    # IO.inspect "key_length: #{p_key_length}"
    result = Keyword.put(result, :key_length, p_key_length)

    {p_key, the_rest} = match_key(p_key_length, the_rest)
    # IO.inspect "key: #{p_key}"
    result = Keyword.put(result, :key, p_key)

    {p_mac, the_rest} = match_mac(the_rest)
    # IO.inspect "mac: #{p_mac}"
    result = Keyword.put(result, :mac, p_mac)

    result

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

  def match_exportibility(<<exportibility::binary-size(1), the_rest::binary>>) do
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

  def match_mac(<<mac::binary-size(8), the_rest::binary>>) do
    {mac, the_rest}
  end


end
