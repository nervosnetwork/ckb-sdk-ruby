# frozen_string_literal: true

module CKB
  module Utils
    def self.bin_to_hex(bin)
      "0x#{bin.unpack1('H*')}"
    end

    def self.valid_hex_string?(hex)
      hex.start_with?("0x") && hex.length.even?
    end

    def self.hex_to_bin(hex)
      raise ArgumentError, "invalid hex string!" unless valid_hex_string?(hex)

      [hex[2..-1]].pack("H*")
    end

    def self.hex_concat(a, b)
      bin_to_hex(hex_to_bin(a) + hex_to_bin(b))
    end

    # @param capacity [Integer] Byte
    #
    # @return [Integer] shannon
    def self.byte_to_shannon(capacity)
      capacity * (10**8)
    end

    # @param num [Integer | String]
    def self.to_int(num)
      return if num.nil?

      return num if num.is_a?(Integer)

      return num.hex if num.is_a?(String) && num.start_with?("0x")

      raise "Can't convert to int!"
    end

    # @param num [Integer | String]
    def self.to_hex(num)
      return if num.nil?

      return "0x" + num.to_s(16) if num.is_a?(Integer)

      return num if num.is_a?(String) && num.start_with?("0x")

      raise "Can't convert to hex string!"
    end

    def self.sudt_amount(output_data)
      CKB::Utils.hex_to_bin(output_data).reverse.unpack1("B*").to_i(2)
    end

    def self.generate_sudt_amount(sudt_amount)
      CKB::Utils.bin_to_hex([sudt_amount].pack("Q<*") + [sudt_amount >> 64].pack("Q<*"))
    end
  end
end
