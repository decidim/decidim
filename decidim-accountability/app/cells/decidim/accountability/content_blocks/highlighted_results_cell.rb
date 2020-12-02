# frozen_string_literal: true

module Decidim
  module Accountability
    module ContentBlocks
      class HighlightedResultsCell < Decidim::ContentBlocks::HighlightedElementsCell
        include Cell::ViewModel::Partial
        include Decidim::IconHelper
        include Decidim::Accountability::ApplicationHelper
        include ActiveSupport::NumberHelper

        def base_relation
          @base_relation ||= Decidim::Accountability::Result.where(component: published_components)
        end
      end
    end
  end
end
