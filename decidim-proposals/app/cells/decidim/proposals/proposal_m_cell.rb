# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Proposals
    # This cell renders a proposal with its M-size card.
    class ProposalMCell < Decidim::CardMCell
      include ProposalCellsHelper

      def badge
        render
      end

      private

      def has_state?
        true
      end

      def has_badge?
        answered? || withdrawn?
      end

      def description
        truncate(model.body, length: 100)
      end

      def badge_classes
        return super unless options[:full_badge]
        state_classes.concat(["label", "proposal-status"]).join(" ")
      end

      def statuses
        [:creation_date, :follow, :endorsements_count, :comments_count]
      end

      def endorsements_count_status
        link_to resource_path do
          with_tooltip t("decidim.proposals.models.proposal.fields.endorsements") do
            icon("bullhorn", class: "icon--small") + " " + model.proposal_endorsements_count.to_s
          end
        end
      end
    end
  end
end
