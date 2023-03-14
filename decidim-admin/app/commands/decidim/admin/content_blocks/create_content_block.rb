# frozen_string_literal: true

module Decidim
  module Admin
    module ContentBlocks
      # A command that reorders a collection of content blocks. It also creates
      # the ones that might be missing.
      class CreateContentBlock < Decidim::Command
        # Public: Initializes the command.
        #
        # organization - the Organization where the content blocks reside
        # scope - the scope applied to the content blocks
        # manifest_name - the manifest name for the content block created
        # scoped_resource_id - (optional) The id of the resource the content blocks belongs to
        def initialize(organization, scope, manifest_name, scoped_resource_id = nil)
          @organization = organization
          @scope = scope
          @manifest_name = manifest_name
          @scoped_resource_id = scoped_resource_id
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the data was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          create_content_block
          broadcast(:ok)
        rescue StandardError
          broadcast(:invalid)
        end

        private

        attr_reader :organization, :scope, :scoped_resource_id, :manifest_name

        def create_content_block
          Decidim::ContentBlock.create!(
            organization:,
            scope_name: scope,
            scoped_resource_id:,
            manifest_name:
          )
        end
      end
    end
  end
end
