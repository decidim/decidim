# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class ParticipatorySpaceDocumentsCell < BaseCell
      COMPONENTS_WITH_DOCUMENTS_COLLECTIONS = [:meetings].freeze

      def components_collections
        components = resource.try(:components)

        return [] if components.blank?

        components = components.where(manifest_name: COMPONENTS_WITH_DOCUMENTS_COLLECTIONS).published

        include_component_name = components.count > 1

        components.map do |component|
          Decidim::ComponentAttachmentCollectionPresenter.new(component, include_component_name:)
        end
      end
    end
  end
end
