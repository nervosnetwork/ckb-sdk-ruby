# frozen_string_literal: true

module CKB
  module Types
    class LocalNodeProtocol
      attr_accessor :id, :name, :support_versions

      # @param id [String]
      # @param name [String]
      # @param support_versions [String[]]
      def initialize(id:, name:, support_versions:)
        @id = Utils.to_int(id)
        @name = name
        @support_versions = support_versions
      end

      def to_h
        {
            id: Utils.to_hex(id),
            name: name,
            support_versions: support_versions
        }
      end

      def self.from_h(hash)
        return if hash.nil?

        new(
            id: hash[:id],
            name: hash[:name],
            support_versions: hash[:support_versions]
        )
      end
    end
  end
end
