# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessGroups
    module ContentBlocks
      class HtmlCell < Decidim::ContentBlocks::HtmlCell
        def block_id
          model.manifest_name.parameterize.gsub("_", "-")
        end
      end
    end
  end
end
