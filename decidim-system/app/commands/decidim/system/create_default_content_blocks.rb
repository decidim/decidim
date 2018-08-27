# frozen_string_literal: true

module Decidim
  module System
    # A command with all the business logic to create the default content blocks
    # for a newly-created organization.
    class CreateDefaultContentBlocks < Rectify::Command
      DEFAULT_CONTENT_BLOCKS =
        [:hero, :sub_hero, :highlighted_content_banner, :how_to_participate, :stats, :footer_sub_hero].freeze

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
        DEFAULT_CONTENT_BLOCKS.each_with_index do |manifest_name, index|
          weight = (index + 1) * 10
          Decidim::ContentBlock.create(
            decidim_organization_id: organization.id,
            weight: weight,
            scope: :homepage,
            manifest_name: manifest_name,
            published_at: Time.current
          )
        end
      end

      private

      attr_reader :organization
    end
  end
end
