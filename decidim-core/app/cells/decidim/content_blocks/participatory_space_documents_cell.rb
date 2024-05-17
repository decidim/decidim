# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class ParticipatorySpaceDocumentsCell < BaseCell
      COMPONENTS_WITH_DOCUMENTS_COLLECTIONS = [:meetings].freeze

      def components_collections
        components = resource.try(:components)

        return [] if components.blank?

        components.where(manifest_name: COMPONENTS_WITH_DOCUMENTS_COLLECTIONS).published.map do |component|
          Decidim::ComponentAttachmentCollectionPresenter.new(component)
        end
      end
    end
  end
end
