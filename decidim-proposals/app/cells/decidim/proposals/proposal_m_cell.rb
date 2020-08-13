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

      def preview?
        options[:preview]
      end

      def title
        decidim_html_escape(present(model).title)
      end

      def body
        decidim_sanitize(present(model).body)
      end

      def has_state?
        model.published?
      end

      def has_badge?
        published_state? || withdrawn?
      end

      def has_link_to_resource?
        model.published?
      end

      def has_footer?
        return false if model.emendation?

        true
      end

      def description
        strip_tags(body).truncate(100, separator: /\s/)
      end

      def badge_classes
        return super unless options[:full_badge]

        state_classes.concat(["label", "proposal-status"]).join(" ")
      end

      def base_statuses
        @base_statuses ||= begin
          if endorsements_visible?
            [:endorsements_count, :comments_count]
          else
            [:comments_count]
          end
        end
      end

      def statuses
        return [] if preview?
        return base_statuses if model.draft?
        return [:creation_date] + base_statuses if !has_link_to_resource? || !can_be_followed?

        [:creation_date, :follow] + base_statuses
      end

      def creation_date_status
        explanation = content_tag(:strong, t("activemodel.attributes.common.created_at"))
        "#{explanation}<br>#{l(model.published_at.to_date, format: :decidim_short)}"
      end

      def endorsements_count_status
        return endorsements_count unless has_link_to_resource?

        link_to resource_path, "aria-label" => "#{t("decidim.endorsable.endorsements_count")}: #{model.endorsements_count}", title: t("decidim.endorsable.endorsements_count") do
          endorsements_count
        end
      end

      def endorsements_count
        with_tooltip t("decidim.endorsable.endorsements") do
          icon("bullhorn", class: "icon--small") + " " + model.endorsements_count.to_s
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

      def can_be_followed?
        !model.withdrawn?
      end

      def endorsements_visible?
        model.component.current_settings.endorsements_enabled?
      end

      def has_image?
        model.attachments.first.present? && model.attachments.first.file.content_type.start_with?("image") && model.component.settings.allow_card_image
      end

      def resource_image_path
        model.attachments.first.url if has_image?
      end
    end
  end
end
