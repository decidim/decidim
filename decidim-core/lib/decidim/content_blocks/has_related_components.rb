# frozen_string_literal: true

module Decidim
  module ContentBlocks
    module HasRelatedComponents
      extend ActiveSupport::Concern

      included do
        def components_for(content_block)
          return if content_block.blank?

          manifest_name = content_block.component_manifest_name
          scope_class = Decidim::ContentBlocks::BaseCell::SCOPE_ASSOCIATIONS[content_block.scope_name]&.safe_constantize

          participatory_space = if scope_class.respond_to?(:participatory_space_manifest)
                                  scope_class.participatory_space_manifest.participatory_spaces.call(content_block.organization).find(content_block.scoped_resource_id)
                                elsif scope_class.respond_to?(:participatory_spaces)
                                  scope_class.participatory_spaces(content_block.scoped_resource_id)
                                end

          if participatory_space.present?
            Decidim::Component.where(participatory_space:, manifest_name:)
          else
            Decidim::PublicComponents.for(content_block.organization, manifest_name:)
          end
        end
      end
    end
  end
end
