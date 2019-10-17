# frozen_string_literal: true

module CKB
  module Types
    class Transaction
      attr_accessor :version, :cell_deps, :header_deps, :inputs, :outputs, :outputs_data, :witnesses, :hash

      # @param hash [String | nil] 0x...
      # @param version [String | Integer] integer or hex number
      # @param cell_deps [CKB::Types::CellDep[]]
      # @param header_deps [String[]]
      # @param inputs [CKB::Types::Input[]]
      # @param outputs [CKB::Types::Output[]]
      # @param outputs_data [String[]]
      # @param witnesses [String[]]
      def initialize(
        hash: nil,
        version: 0,
        cell_deps: [],
        header_deps: [],
        inputs: [],
        outputs: [],
        outputs_data: [],
        witnesses: []
      )
        @hash = hash
        @version = Utils.to_int(version)
        @cell_deps = cell_deps
        @header_deps = header_deps
        @inputs = inputs
        @outputs = outputs
        @outputs_data = outputs_data
        @witnesses = witnesses
      end

      # @param key [CKB::Key]
      # @param tx_hash [String] 0x...
      def sign(key, tx_hash)
        raise "Invalid number of witnesses!" if witnesses.length < inputs.length

        signed_witnesses = witnesses.map do |witness|
          old_datum = witness
          blake2b = CKB::Blake2b.new
          blake2b.update(Utils.hex_to_bin(tx_hash))
          blake2b.update(Utils.hex_to_bin(old_datum))
          message = blake2b.hexdigest
          data = key.sign_recoverable(message) + old_datum[2..-1]

          data
        end

        self.class.new(
          hash: tx_hash, # using real tx_hash instead
          version: version,
          cell_deps: cell_deps,
          header_deps: header_deps,
          inputs: inputs,
          outputs: outputs,
          outputs_data: outputs_data,
          witnesses: signed_witnesses
        )
      end

      # @param index [Integer]
      # @param key [CKB::Key]
      #
      # @return [CKBP::Types::Transaction]
      def sign_input(index, key)
        @hash = @hash || compute_hash

        witness = witnesses[index] || ""

        blake2b = CKB::Blake2b.new
        blake2b.update(Utils.hex_to_bin(@hash))
        blake2b.update(Utils.hex_to_bin(witness))
        message = blake2b.hexdigest
        signed_witness = key.sign_recoverable(message) + witness[2..-1]

        witnesses[index] = signed_witness

        self
      end

      def to_h
        hash = to_raw_transaction_h
        hash[:hash] = @hash if @hash

        hash
      end

      def to_raw_transaction_h
        {
          version: Utils.to_hex(@version),
          cell_deps: @cell_deps.map(&:to_h),
          header_deps: @header_deps,
          inputs: @inputs.map(&:to_h),
          outputs: @outputs.map(&:to_h),
          outputs_data: @outputs_data,
          witnesses: @witnesses
        }
      end

      def compute_hash
        raw_transaction_serializer = CKB::Serializers::RawTransactionSerializer.new(self)
        blake2b = CKB::Blake2b.new
        blake2b << Utils.hex_to_bin(raw_transaction_serializer.serialize)
        blake2b.hexdigest
      end

      def serialized_size_in_block
        transaction_serializer = CKB::Serializers::TransactionSerializer.new(self)
        serialized_tx_offset_bytesize = 4 # 4 bytes for the tx offset cost with molecule array (transactions)
        Utils.hex_to_bin(transaction_serializer.serialize).bytesize + serialized_tx_offset_bytesize
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          hash: hash[:hash],
          version: hash[:version],
          header_deps: hash[:header_deps],
          cell_deps: hash[:cell_deps].map { |dep| CellDep.from_h(dep) },
          inputs: hash[:inputs].map { |input| Input.from_h(input) },
          outputs: hash[:outputs].map { |output| Output.from_h(output) },
          outputs_data: hash[:outputs_data],
          witnesses: hash[:witnesses]
        )
      end
    end
  end
end
