# frozen_string_literal: true

module Decidim
  module ContentBlocks
    module HasRelatedComponents
      extend ActiveSupport::Concern

      included do
        def components_for(content_block)
          return if content_block.blank?

          manifest_name = content_block.component_manifest_name
          case content_block.scope_name
          when "participatory_process_group_homepage"
            participatory_space = Decidim::ParticipatoryProcessGroup.find(content_block.scoped_resource_id).participatory_processes
            Decidim::Component.where(participatory_space:, manifest_name:)
          when "participatory_process_homepage"
            Decidim::ParticipatoryProcess.find(content_block.scoped_resource_id).components.where(manifest_name:)
          else
            Decidim::PublicComponents.for(content_block.organization, manifest_name:)
          end
        end
      end
    end
  end
end
