# frozen_string_literal: true

module Decidim
  module System
    # A command with all the business logic to create the default content blocks
    # for a newly-created organization.
    class CreateDefaultContentBlocks < Decidim::Command
      DEFAULT_CONTENT_BLOCKS =
        [:hero, :sub_hero, :highlighted_content_banner, :how_to_participate, :stats, :metrics, :footer_sub_hero].freeze

      # Public: Initializes the command.
      #
      # form - A form object with the params.
      def initialize(organization)
        @organization = organization
      end

      # Executes the command.
      #
      # Returns nothing.
      def call
        Decidim::ContentBlocksCreator.new(organization).create_default!
      end

      private

      attr_reader :organization
    end
  end
end
