# frozen_string_literal: true

module Decidim
  module ContentBlocks
    module HasRelatedComponents
      extend ActiveSupport::Concern

      included do
        # This method allows us to detect the components related whith a
        # content block. The content block can have different components
        # associated depending on the scope_name. The scope names and their
        # associated models are configured in Decidim::ContentBlocks::BaseCell
        # and depending on the type of model there can be a single
        # participatory space which can be obtained via manifest or
        # multiple spaces which can be obtained by calling a function provided by
        # the class
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
