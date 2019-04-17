# frozen_string_literal: true

require "secp256k1"

module CKB
  module Utils
    def self.bin_to_hex(bin)
      "0x#{bin.unpack1('H*')}"
    end

    def self.valid_hex_string?(hex)
      hex.start_with?("0x") && hex.length.even?
    end

    def self.extract_pubkey(privkey)
      privkey_bin = hex_to_bin(privkey)
      pubkey_bin = Secp256k1::PrivateKey.new(privkey: privkey_bin).pubkey.serialize
      bin_to_hex(pubkey_bin)
    end

    def self.json_script_to_type_hash(script)
      blake2b = CKB::Blake2b.new
      blake2b << hex_to_bin(script[:binary_hash]) if script[:binary_hash]
      args = script[:args] || []
      args.each do |arg|
        blake2b << hex_to_bin(arg)
      end
      bin_to_hex(blake2b.digest)
    end

    def self.sign_sighash_all_inputs(inputs, outputs, privkey, _pubkeys)
      blake2b = CKB::Blake2b.new
      inputs.each do |input|
        previous_output = input[:previous_output]
        blake2b.update(hex_to_bin(previous_output[:hash]))
        blake2b.update(previous_output[:index].to_s)
      end
      outputs.each do |output|
        blake2b.update(output[:capacity].to_s)
        blake2b.update(hex_to_bin(json_script_to_type_hash(output[:lock])))
        next unless output[:type]

        blake2b.update(
          hex_to_bin(
            json_script_to_type_hash(output[:type])
          )
        )
      end
      privkey_bin = hex_to_bin(privkey)
      key = Secp256k1::PrivateKey.new(privkey: privkey_bin)
      signature_bin = key.ecdsa_serialize(
        key.ecdsa_sign(blake2b.digest, raw: true)
      )
      signature_hex = bin_to_hex(signature_bin)

      witnesses = inputs.zip(pubkeys).map do |_input, pubkey|
        # Same as lock arguments, the witness data here will be considered hex
        # strings by the C script, those exact hex strings are binaries to the
        # SDK, hence we also need 2 binary to hex string conversions.
        {
          data: [
            CKB::Utils.bin_to_hex(CKB::Utils.hex_to_bin(pubkey).unpack1("H*")),
            CKB::Utils.bin_to_hex(CKB::Utils.hex_to_bin(signature_hex).unpack1("H*"))
          ]
        }
      end

      [inputs, witnesses]
    end

    def self.pubkey_blake160(pubkey)
      pubkey_bin = hex_to_bin(pubkey)
      hash_bin = CKB::Blake2b.digest(pubkey_bin)
      bin_to_hex(hash_bin[0...20])
    end

    # payload = type(01) | bin-idx("P2PH" => "50/32/50/48") | pubkey blake160
    # see https://github.com/nervosnetwork/ckb/wiki/Common-Address-Format for more info.
    def self.generate_address(prefix, pubkey_blake160)
      pubkey_blake160_bin = hex_to_bin(pubkey_blake160)
      payload = ["0150325048"].pack("H*") + pubkey_blake160_bin
      CKB::ConvertAddress.encode(prefix, payload)
    end

    def self.parse_address(address, prefix)
      decoded_prefix, data = CKB::ConvertAddress.decode(address)
      raise "Invalid prefix" if decoded_prefix != prefix

      raise "Invalid type/bin-idx" if data.slice(0..4) != ["0150325048"].pack("H*")

      CKB::Utils.bin_to_hex(data.slice(5..-1))
    end

    def self.generate_lock(target_pubkey_blake160, system_script_cell_hash)
      target_pubkey_blake160_bin = CKB::Utils.hex_to_bin(target_pubkey_blake160)
      {
        binary_hash: system_script_cell_hash,
        args: [
          # There are 2 conversions from binary to hex string here:
          # 1. The inner unpack1 is required since the deployed lock script
          # now accepts a hex string version of the public key hash so we can
          # treat it as a null-terminated string in C for ease of processing.
          # So even though the inner unpack1 already converts the public key
          # hash binary to a hex string format, we should still see it as a
          # binary from the SDK point of view.
          # 2. The outer bin_to_hex then converts the binary (in SDK
          # point of view) to a hex string required by CKB RPC.
          CKB::Utils.bin_to_hex(target_pubkey_blake160_bin.unpack1("H*"))
        ]
      }
    end

    private

    # Conversions from hex string to binary is kept as private method
    # so we can ensure code outside of this utils module only needs to deal
    # with hex strings
    def self.hex_to_bin(hex)
      raise ArgumentError, "invalid hex string!" unless valid_hex_string?(hex)

      [hex[2..-1]].pack("H*")
    end
  end
end
