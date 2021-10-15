# frozen_string_literal: true

module CKB
  module ConvertAddress
    class << self
      # This method taken from: https://github.com/sipa/bech32/blob/bdc264f84014c234e908d72026b7b780122be11f/ref/ruby/segwit_addr.rb#L64-L85
      def convert_bits(data, from, to, padding = true)
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

      def encode(hrp, data, spec)
        data = convert_bits(data.bytes, 8, 5)
        Bech32.encode(hrp, data, spec)
      end

      def decode(bech)
        hrp, data, spec = Bech32.decode(bech)
        [hrp, convert_bits(data, 5, 8, false).map(&:chr).join, spec]
      end
    end
  end
end
