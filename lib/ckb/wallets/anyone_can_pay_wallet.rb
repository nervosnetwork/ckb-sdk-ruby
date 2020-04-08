# frozen_string_literal: true

module CKB
  module Wallets
    class AnyoneCanPayWallet < NewWallet
      attr_reader :sudt_type_script, :sudt_args
      attr_accessor :anyone_can_pay_cell_lock_scripts, :need_sudt, :is_owner

      def initialize(api:, from_addresses:, anyone_can_pay_addresses:, sudt_args:, collector_type: :default_scanner, mode: MODE::TESTNET, from_block_number: 0)
        super(api: api, from_addresses: from_addresses, collector_type: collector_type, mode: mode, from_block_number: from_block_number)
        @sudt_args = sudt_args
        @sudt_type_script = CKB::Types::Script.new(code_hash: CKB::Config::SUDT_CODE_HASH, args: sudt_args, hash_type: "data")
        @anyone_can_pay_cell_lock_scripts = (anyone_can_pay_addresses.is_a?(Array) ? anyone_can_pay_addresses : [anyone_can_pay_addresses]).map do |address|
          script = CKB::AddressParser.new(address).parse.script
          raise "not an anyone can pay address" if script.code_hash != CKB::Config::ANYONE_CAN_PAY_CODE_HASH

          script
        end
        @is_owner = input_scripts.size == 1 && input_scripts.first.compute_hash == anyone_can_pay_cell_lock_scripts.first.compute_hash
        @need_sudt = true
      end

      def generate(to_address, transfer_info, output_info ={}, fee_rate = 1)
        transfer_type, transfer_amount = transfer_info[:type], transfer_info[:amount]
        type = sudt_type_script
        case transfer_type
        when :ckb
          capacity = transfer_amount
          data = "0x#{'0' * 32}"
          @need_sudt = false
        when :udt
          capacity = is_owner ? CKB::Utils.byte_to_shannon(142) : 0
          data = CKB::Utils.generate_sudt_amount(transfer_amount)
        else
          raise "wrong transfer type, only support ckb or udt"
        end

        advance_generate(
          to_infos: {
            to_address => { capacity: capacity, type: type, data: data }
          },
          contexts: [output_info[:context]],
          fee_rate: fee_rate
        )
      end

      def advance_generate(to_infos: , contexts: [], fee_rate: 1)
        outputs = []
        outputs_data = []

        to_infos.each do |address, output_info|
          lock = CKB::AddressParser.new(address).parse.script
          raise "unexpected anyone can pay address" if lock.code_hash == CKB::Config::ANYONE_CAN_PAY_CODE_HASH && !anyone_can_pay_cell_lock_scripts.map(&:compute_hash).include?(lock.compute_hash)

          capacity = [output_info[:capacity], CKB::Utils.byte_to_shannon(142)].max
          outputs << CKB::Types::Output.new(capacity: capacity, lock: lock, type: output_info[:type])
          outputs_data << (output_info[:data] || "0x")
        end

        if outputs.all? { |output| output.capacity > 0 } || (outputs.map { |output| output.capacity }.sum == 0)
          if to_infos.any? { |_, output_info| output_info[:type] && output_info[:type].compute_hash == sudt_type_script.compute_hash }
            outputs << CKB::Types::Output.new(capacity: 0, lock: input_scripts[-1], type: nil)
            outputs_data << "0x"
            if need_sudt
              outputs << CKB::Types::Output.new(capacity: CKB::Utils.byte_to_shannon(142), lock: input_scripts[-1], type: sudt_type_script)
              outputs_data << "0x#{'0' * 32}"
            end
          else
            outputs << CKB::Types::Output.new(capacity: 0, lock: input_scripts[-1], type: nil)
            outputs_data << "0x"
          end
        end

        transaction = CKB::Types::Transaction.new(
          version: 0, cell_deps: [], header_deps: [], inputs: [],
          outputs: outputs, outputs_data: outputs_data, witnesses: []
        )

        tx_generator = CKB::AnyoneCanPayTransactionGenerator.new(api, transaction)
        tx_generator.need_sudt = need_sudt
        tx_generator.sudt_args = sudt_args
        tx_generator.is_owner = is_owner
        tx_generator.anyone_can_pay_cell_lock_scripts = anyone_can_pay_cell_lock_scripts
        tx_generator.generate(anyone_can_pay_collector: anyone_can_pay_collector, udt_collector: udt_collector, capacity_collector: capacity_collector, contexts: input_scripts.map(&:compute_hash).zip(contexts).to_h, fee_rate: fee_rate)

        tx_generator
      end

      private

      def sender_cell?(cell_meta)
        return true if is_owner

        sender_scripts = input_scripts.reject { |script| anyone_can_pay_cell_lock_scripts.map(&:compute_hash).include?(script.compute_hash) }
        sender_scripts.map(&:compute_hash).include?(cell_meta.output.lock.compute_hash)
      end

      def sender_normal_cell?(cell_meta)
        normal_cell?(cell_meta) && sender_cell?(cell_meta)
      end

      def sender_udt_cell?(cell_meta)
        sudt_cell?(cell_meta) && sender_cell?(cell_meta)
      end

      def receiver_anyone_can_pay_cell?(cell_meta)
        lock = cell_meta.output.lock
        lock.code_hash == CKB::Config::ANYONE_CAN_PAY_CODE_HASH && anyone_can_pay_cell_lock_scripts.map(&:compute_hash).include?(lock.compute_hash)
      end

      def normal_cell?(cell_meta)
        cell_meta.output_data_len.zero? && cell_meta.output.type.nil?
      end

      def sudt_cell?(cell_meta)
        cell_meta.output.type && cell_meta.output.type.compute_hash == sudt_type_script.compute_hash
      end

      def anyone_can_pay_collector
        collector =
          if collector_type == :default_scanner
            CKB::Collector.new(api).default_scanner(lock_hashes: input_scripts.map(&:compute_hash), from_block_number: from_block_number)
          else
            CKB::Collector.new(api).default_indexer(lock_hashes: input_scripts.map(&:compute_hash))
          end

        Enumerator.new do |result|
          loop do
            begin
              cell_meta = collector.next
              if receiver_anyone_can_pay_cell?(cell_meta)
                result << cell_meta
              end
            rescue StopIteration
              break
            end
          end
        end
      end

      def udt_collector
        collector =
          if collector_type == :default_scanner
            CKB::Collector.new(api).default_scanner(lock_hashes: input_scripts.map(&:compute_hash), from_block_number: from_block_number)
          else
            CKB::Collector.new(api).default_indexer(lock_hashes: input_scripts.map(&:compute_hash))
          end

        Enumerator.new do |result|
          loop do
            begin
              cell_meta = collector.next
              if sender_udt_cell?(cell_meta)
                result << cell_meta
              end
            rescue StopIteration
              break
            end
          end
        end
      end

      def capacity_collector
        collector =
          if collector_type == :default_scanner
            CKB::Collector.new(api).default_scanner(lock_hashes: input_scripts.map(&:compute_hash), from_block_number: from_block_number)
          else
            CKB::Collector.new(api).default_indexer(lock_hashes: input_scripts.map(&:compute_hash))
          end

        Enumerator.new do |result|
          loop do
            begin
              cell_meta = collector.next
              if sender_normal_cell?(cell_meta)
                result << cell_meta
              end
            rescue StopIteration
              break
            end
          end
        end
      end
    end
  end
end
