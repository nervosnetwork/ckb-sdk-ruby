# frozen_string_literal: true

module CKB
  module Types
    class ChainInfo
      attr_accessor :is_initial_block_download, :epoch, :difficulty, :median_time, :chain, :alerts

      # @param is_initialize_block_download [Boolean]
      # @param epoch [String | Integer] integer or hex number
      # @param difficulty [String | Integer] integer or hex number
      # @param median_time [String | Integer] timestamp
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
        @epoch = Utils.to_int(epoch)
        @difficulty = Utils.to_int(difficulty)
        @median_time = Utils.to_int(median_time)
        @chain = chain
        @alerts = alerts
      end

      def to_h
        {
          is_initial_block_download: @is_initial_block_download,
          epoch: Utils.to_hex(@epoch),
          difficulty: Utils.to_hex(@difficulty),
          median_time: Utils.to_hex(@median_time),
          chain: @chain,
          alerts: @alerts.map(&:to_h)
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
