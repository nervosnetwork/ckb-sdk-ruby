# Taken from https://github.com/sipa/bech32/blob/bdc264f84014c234e908d72026b7b780122be11f/ref/ruby/bech32.rb
# Modified to add this function: https://github.com/sipa/bech32/blob/bdc264f84014c234e908d72026b7b780122be11f/ref/ruby/segwit_addr.rb#L64-L85

# Copyright (c) 2017 Shigeyuki Azuchi
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

module Bech32

  SEPARATOR = '1'

  CHARSET = %w(q p z r y 9 x 8 g f 2 t v d w 0 s 3 j n 5 4 k h c e 6 m u a 7 l)

  module_function

  def convert_bits(data, from, to, padding=true)
    acc = 0
    bits = 0
    ret = []
    maxv = (1 << to) - 1
    max_acc = (1 << (from + to - 1)) - 1
    data.each do |v|
      return nil if v < 0 || (v >> from) != 0
      acc = ((acc << from) | v) & max_acc
      bits += from
      while bits >= to
        bits -= to
        ret << ((acc >> bits) & maxv)
      end
    end
    if padding
      ret << ((acc << (to - bits)) & maxv) unless bits == 0
    elsif bits >= from || ((acc << (to - bits)) & maxv) != 0
      return nil
    end
    ret
  end

  # Encode Bech32 string
  def encode(hrp, data)
    data = convert_bits(data.bytes, 8, 5)
    checksummed = data + create_checksum(hrp, data)
    hrp + SEPARATOR + checksummed.map{|i|CHARSET[i]}.join
  end

  # Decode a Bech32 string and determine hrp and data
  def decode(bech)
    # check invalid bytes
    return nil if bech.scrub('?').include?('?')
    # check uppercase/lowercase
    return nil if (bech.downcase != bech && bech.upcase != bech)
    bech.each_char{|c|return nil if c.ord < 33 || c.ord > 126}
    bech = bech.downcase
    # check data length
    pos = bech.rindex(SEPARATOR)
    return nil if pos.nil? || pos < 1 || pos + 7 > bech.length || bech.length > 90
    # check valid charset
    bech[pos+1..-1].each_char{|c|return nil unless CHARSET.include?(c)}
    # split hrp and data
    hrp = bech[0..pos-1]
    data = bech[pos+1..-1].each_char.map{|c|CHARSET.index(c)}
    # check checksum
    return nil unless verify_checksum(hrp, data)
    [hrp, convert_bits(data[0..-7], 5, 8, false).map(&:chr).join]
  end

  # Compute the checksum values given hrp and data.
  def create_checksum(hrp, data)
    values = expand_hrp(hrp) + data
    polymod = polymod(values + [0, 0, 0, 0, 0, 0]) ^ 1
    (0..5).map{|i|(polymod >> 5 * (5 - i)) & 31}
  end

  # Verify a checksum given Bech32 string
  def verify_checksum(hrp, data)
    polymod(expand_hrp(hrp) + data) == 1
  end

  # Expand the hrp into values for checksum computation.
  def expand_hrp(hrp)
    hrp.each_char.map{|c|c.ord >> 5} + [0] + hrp.each_char.map{|c|c.ord & 31}
  end

  # Compute Bech32 checksum
  def polymod(values)
    generator = [0x3b6a57b2, 0x26508e6d, 0x1ea119fa, 0x3d4233dd, 0x2a1462b3]
    chk = 1
    values.each do |v|
      top = chk >> 25
      chk = (chk & 0x1ffffff) << 5 ^ v
      (0..4).each{|i|chk ^= ((top >> i) & 1) == 0 ? 0 : generator[i]}
    end
    chk
  end

  private_class_method :polymod, :expand_hrp

end
