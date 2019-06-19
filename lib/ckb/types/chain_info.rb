# frozen_string_literal: true

module CKB
  module Types
    class ChainInfo
      attr_reader :is_initial_block_download, :epoch, :difficulty, :median_time, :chain, :alerts

      # @param is_initialize_block_download [Boolean]
      # @param epoch [String] number
      # @param difficulty [String] 0x...
      # @param median_time [String] timestamp
      # @param chain [String]
      # @param alerts [Types::AlertMessage]
      def initialize(
        is_initial_block_download:,
        epoch:,
        difficulty:,
        median_time:,
        chain:,
        alerts:
      )
        @is_initial_block_download = is_initial_block_download
        @epoch = epoch
        @difficulty = difficulty
        @median_time = median_time
        @chain = chain
        @alerts = alerts
      end

      def to_h
        {
          is_initial_block_download: @is_initial_block_download,
          epoch: @epoch,
          difficulty: @difficulty,
          median_time: @median_time,
          chain: @chain,
          alerts: @alerts
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
          is_initial_block_download: hash[:is_initial_block_download],
          epoch: hash[:epoch],
          difficulty: hash[:difficulty],
          median_time: hash[:median_time],
          chain: hash[:chain],
          alerts: hash[:alerts]&.map { |alert| Types::AlertMessage.from_h(alert) }
        )
      end
    end
  end
end
