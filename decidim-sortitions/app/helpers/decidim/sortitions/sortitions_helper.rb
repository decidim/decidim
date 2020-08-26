# frozen_string_literal: true

module Decidim
  module Sortitions
    module SortitionsHelper
      include Decidim::SanitizeHelper
      include Decidim::TranslationsHelper

      def proposal_path(proposal)
        EngineRouter.main_proxy(proposal.component).proposal_path(proposal)
      end

      # Generates the sortition category label
      def sortition_category_label(sortition)
        if sortition.category.present?
          return I18n.t("show.category",
                        scope: "decidim.sortitions.sortitions",
                        category: translated_attribute(sortition.category.name))
        end

        I18n.t("show.any_category", scope: "decidim.sortitions.sortitions")
      end

      # Show list of candidate proposals for a sortition. Selected sortition ids will appear with bold font.
      def sortition_proposal_candidate_ids(sortition)
        result = []
        sortition.candidate_proposals.each do |proposal_id|
          result << if sortition.selected_proposals.include? proposal_id
                      "<b>#{proposal_id}</b>"
                    else
                      proposal_id.to_s
                    end
        end

        result.join(", ").html_safe
      end
    end
  end
end
