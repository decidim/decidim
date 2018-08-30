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

      def title
        present(model).title
      end

      def body
        present(model).body
      end

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
        truncate(present(model).html_body, length: 100)
      end

      def badge_classes
        return super unless options[:full_badge]
        state_classes.concat(["label", "proposal-status"]).join(" ")
      end

      def statuses
        return [:endorsements_count, :comments_count] if model.draft?
        return [:creation_date, :endorsements_count, :comments_count] unless has_link_to_resource?
        [:creation_date, :follow, :endorsements_count, :comments_count]
      end

      def creation_date_status
        l(model.published_at.to_date, format: :decidim_short)
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

      def progress_bar_progress
        model.proposal_votes_count || 0
      end

      def progress_bar_total
        model.maximum_votes || 0
      end

      def progress_bar_subtitle_text
        if progress_bar_progress >= progress_bar_total
          t("decidim.proposals.proposals.votes_count.most_popular_proposal")
        else
          t("decidim.proposals.proposals.votes_count.need_more_votes")
        end
      end
    end
  end
end
