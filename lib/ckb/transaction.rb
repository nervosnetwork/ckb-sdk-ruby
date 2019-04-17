# frozen_string_literal: true

module CKB
  class Transaction
    attr_reader :version, :deps, :inputs, :outputs, :witnesses

    def initialize(version: 0, deps: [], inputs: [], outputs: [], witnesses: [])
      @version = version
      @deps = deps
      @inputs = inputs
      @outputs = outputs
      @witnesses = witnesses
    end

    def sign(key)
      signature_hex_var = signature_hex(key)

      witnesses = inputs.map do |_input|
        # Same as lock arguments, the witness data here will be considered hex
        # strings by the C script, those exact hex strings are binaries to the
        # SDK, hence we also need 2 binary to hex string conversions.
        {
          data: [
            CKB::Utils.bin_to_hex(
              CKB::Utils.hex_to_bin(key.pubkey).unpack1("H*")
            ),
            CKB::Utils.bin_to_hex(
              CKB::Utils.hex_to_bin(signature_hex_var).unpack1("H*")
            )
          ]
        }
      end

      self.class.new(
        version: version,
        deps: deps,
        inputs: inputs,
        outputs: outputs,
        witnesses: witnesses
      )
    end

    def to_h
      {
        version: @version,
        deps: @deps,
        inputs: @inputs,
        outputs: @outputs,
        witnesses: @witnesses
      }
    end

    private

    def signature_hex(key)
      blake2b = CKB::Blake2b.new
      inputs.each do |input|
        previous_output = input[:previous_output]
        blake2b.update(Utils.hex_to_bin(previous_output[:hash]))
        blake2b.update(previous_output[:index].to_s)
      end
      outputs.each do |output|
        blake2b.update(output[:capacity].to_s)
        blake2b.update(
          Utils.hex_to_bin(
            Utils.json_script_to_type_hash(output[:lock])
          )
        )
        next unless output[:type]

        blake2b.update(
          Utils.hex_to_bin(
            Utils.json_script_to_type_hash(output[:type])
          )
        )
      end
      privkey_bin = Utils.hex_to_bin(key.privkey)
      secp_key = Secp256k1::PrivateKey.new(privkey: privkey_bin)
      signature_bin = secp_key.ecdsa_serialize(
        secp_key.ecdsa_sign(blake2b.digest, raw: true)
      )
      Utils.bin_to_hex(signature_bin)
    end
  end
end
