# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Proposals
    # This cell renders a proposal with its M-size card.
    class ProposalMCell < Decidim::CardMCell
      include ProposalCellsHelper

      delegate :current_locale, to: :controller

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
        decidim_sanitize_editor(present(model).body)
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
        @base_statuses ||= if endorsements_visible?
                             [:endorsements_count, :comments_count]
                           else
                             [:comments_count]
                           end
      end

      def statuses
        return [] if preview?
        return base_statuses if model.draft?
        return [:creation_date] + base_statuses if !has_link_to_resource? || !can_be_followed?

        [:creation_date, :follow] + base_statuses
      end

      def creation_date_status
        explanation = tag.strong(t("activemodel.attributes.common.created_at"))
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
          "#{icon("bullhorn", class: "icon--small")} #{model.endorsements_count}"
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
        @has_image ||= model.attachments.map(&:image?).any?
      end

      def resource_image_path
        @resource_image_path ||= has_image? ? model.attachments.find_by("content_type like '%image%'").thumbnail_url : nil
      end

      def cache_hash
        hash = []
        hash << I18n.locale.to_s
        hash << model.cache_key_with_version
        hash << model.proposal_votes_count
        hash << model.endorsements_count
        hash << model.comments_count
        hash << Digest::MD5.hexdigest(model.component.cache_key_with_version)
        hash << Digest::MD5.hexdigest(resource_image_path) if resource_image_path
        hash << render_space? ? 1 : 0
        if current_user
          hash << current_user.cache_key_with_version
          hash << current_user.follows?(model) ? 1 : 0
        end
        hash << model.follows_count
        hash << Digest::MD5.hexdigest(model.authors.map(&:cache_key_with_version).to_s)
        hash << (model.must_render_translation?(model.organization) ? 1 : 0) if model.respond_to?(:must_render_translation?)
        hash << model.component.participatory_space.active_step.id if model.component.participatory_space.try(:active_step)
        hash << has_footer?
        hash << has_actions?

        hash.join(Decidim.cache_key_separator)
      end
    end
  end
end
