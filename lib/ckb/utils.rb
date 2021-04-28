# frozen_string_literal: true

module CKB
  module Utils
    def self.bin_to_hex(bin)
      "0x#{bin.unpack('H*').first}"
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

      return "0x#{num.to_s(16)}" if num.is_a?(Integer)

      return num if num.is_a?(String) && num.start_with?("0x")

      raise "Can't convert to hex string!"
    end

    def self.sudt_amount!(output_data)
      return 0 if output_data == "0x"
      output_data_bin = CKB::Utils.hex_to_bin(output_data)
      raise "Invalid sUDT amount" if output_data_bin.bytesize < 16

      values = output_data_bin[0..15].unpack("Q<Q<")
      (values[1] << 64) | values[0]
    end

    def self.generate_sudt_amount(sudt_amount)
      values = [sudt_amount & 0xFFFFFFFFFFFFFFFF, (sudt_amount >> 64) & 0xFFFFFFFFFFFFFFFF]
      CKB::Utils.bin_to_hex(values.pack("Q<Q<"))
    end
  end
end
