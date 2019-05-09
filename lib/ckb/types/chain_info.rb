# frozen_string_literal: true

module CKB
  module Types
    class ChainInfo
      attr_reader :is_initial_block_download, :epoch, :difficulty, :median_time, :chain, :warnings

      # @param is_initialize_block_download [Boolean]
      # @param epoch [String] number
      # @param difficulty [String] 0x...
      # @param median_time [String] timestamp
      # @param chain [String]
      # @param warnings [String]
      def initialize(
        is_initial_block_download:,
        epoch:,
        difficulty:,
        median_time:,
        chain:,
        warnings:
      )
        @is_initial_block_download = is_initial_block_download
        @epoch = epoch
        @difficulty = difficulty
        @median_time = median_time
        @chain = chain
        @warnings = warnings
      end

      def to_h
        {
          is_initial_block_download: @is_initial_block_download,
          epoch: @epoch,
          difficulty: @difficulty,
          median_time: @median_time,
          chain: @chain,
          warnings: @warnings
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
          warnings: hash[:warnings]
        )
      end
    end
  end
end
