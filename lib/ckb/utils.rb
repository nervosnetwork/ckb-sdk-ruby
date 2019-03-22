# frozen_string_literal: true

require "secp256k1"

module CKB
  module Utils
    def self.hex_to_bin(hex)
      hex = hex[2..-1] if hex.start_with?("0x")
      [hex].pack("H*")
    end

    def self.bin_to_hex(bin)
      bin.unpack1("H*")
    end

    def self.bin_to_prefix_hex(bin)
      "0x#{bin_to_hex(bin)}"
    end

    def self.extract_pubkey_bin(privkey_bin)
      Secp256k1::PrivateKey.new(privkey: privkey_bin).pubkey.serialize
    end

    def self.json_script_to_type_hash(script)
      blake2b = CKB::Blake2b.new
      blake2b << hex_to_bin(script[:reference]) if script[:reference]
      blake2b << "|"
      blake2b << script[:binary] if script[:binary]
      signed_args = script[:signed_args] || []
      signed_args.each do |arg|
        blake2b << arg
      end
      bin_to_prefix_hex(blake2b.digest)
    end

    def self.sign_sighash_all_inputs(inputs, outputs, privkey)
      blake2b = CKB::Blake2b.new
      sighash_type = 0x1.to_s
      blake2b.update(sighash_type)
      inputs.each do |input|
        previous_output = input[:previous_output]
        blake2b.update(hex_to_bin(previous_output[:hash]))
        blake2b.update(previous_output[:index].to_s)
        blake2b.update(
          hex_to_bin(
            json_script_to_type_hash(input[:unlock])
          )
        )
      end
      outputs.each do |output|
        blake2b.update(output[:capacity].to_s)
        blake2b.update(hex_to_bin(output[:lock]))
        next unless output[:type]

        blake2b.update(
          hex_to_bin(
            json_script_to_type_hash(output[:type])
          )
        )
      end
      key = Secp256k1::PrivateKey.new(privkey: privkey)
      signature_bin = key.ecdsa_serialize(
        key.ecdsa_sign(blake2b.digest, raw: true)
      )
      signature_hex = bin_to_hex(signature_bin)

      inputs.map do |input|
        unlock = input[:unlock].merge(args: [signature_hex, sighash_type])
        input.merge(unlock: unlock)
      end
    end

    # In Ruby, bytes are represented using String,
    # since JSON has no native byte arrays,
    # CKB convention bytes passed with a "0x" prefix hex encoding,
    # hence we have to do type conversions here.
    def self.normalize_tx_for_json!(transaction)
      transaction[:inputs].each do |input|
        unlock = input[:unlock]
        unlock[:args] = unlock[:args].map { |arg| bin_to_prefix_hex(arg) }
        unlock[:signed_args] = unlock[:signed_args].map { |arg| bin_to_prefix_hex(arg) }
        next unless unlock[:binary]

        unlock[:binary] = bin_to_prefix_hex(unlock[:binary])
      end

      transaction[:outputs].each do |output|
        output[:data] = bin_to_prefix_hex(output[:data])
        next unless output[:type]

        type = output[:type]
        type[:args] = type[:args].map { |arg| bin_to_prefix_hex(arg) }
        type[:signed_args] = type[:signed_args].map { |arg| bin_to_prefix_hex(arg) }
        type[:binary] = bin_to_prefix_hex(type[:binary]) if type[:binary]
      end

      transaction
    end
  end
end
