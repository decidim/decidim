# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessGroups
    module ContentBlocks
      class MetadataCell < Decidim::ViewModel
        include Decidim::SanitizeHelper

        def participatory_process_group
          @participatory_process_group ||= Decidim::ParticipatoryProcessGroup.find(model.scoped_resource_id)
        end
      end
    end
  end
end
