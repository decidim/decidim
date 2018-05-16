# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Proposals
    # This cell renders a proposal with its M-size card.
    class ProposalMCell < Decidim::CardMCell
      include ProposalCellsHelper

      def badge
        render if has_badge?
      end

      private

      def has_state?
        model.published?
      end

      def has_badge?
        answered? || withdrawn?
      end

      def has_link_to_resource?
        model.published?
      end

      def description
        truncate(model.body, length: 100)
      end

      def badge_classes
        return super unless options[:full_badge]
        state_classes.concat(["label", "proposal-status"]).join(" ")
      end

      def statuses
        return [:creation_date, :endorsements_count, :comments_count] unless has_link_to_resource?
        [:creation_date, :follow, :endorsements_count, :comments_count]
      end

      def endorsements_count_status
        return endorsements_count unless has_link_to_resource?

        link_to resource_path do
          endorsements_count
        end
      end

      def endorsements_count
        with_tooltip t("decidim.proposals.models.proposal.fields.endorsements") do
          icon("bullhorn", class: "icon--small") + " " + model.proposal_endorsements_count.to_s
        end
      end
    end
  end
end
