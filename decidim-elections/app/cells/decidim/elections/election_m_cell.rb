# frozen_string_literal: true

module Decidim
  module Elections
    # This cell renders the Medium (:m) election card
    # for a given instance of an Election
    class ElectionMCell < Decidim::CardMCell
      include ElectionCellsHelper

      def date
        render
      end

      private

      def has_state?
        true
      end

      def title
        present(model).title
      end

      def resource_icon
        icon "elections", class: "icon--big"
      end

      # Even though we need to render the badge, we can't do it in the normal
      # way, because the paragraph comes from a user input and contains HTML.
      # This causes the badge and the paragraph to appear in different lines.
      # In order to fix it, check the `description` method.
      def has_badge?
        false
      end

      def badge_name
        text = model.voting_period_status
        return unless text

        I18n.t(text, scope: "decidim.elections.election_m.badge_name")
      end

      # In order to render the badge inline with the paragraph text we need to
      # find the opening `<p>` tag and include the badge right after it. This
      # makes the layout look good.
      def has_image?
        model.photos.present?
      end

      def resource_image_path
        model.photos.first.url if has_image?
      end

      def description
        text = super
        text.gsub!(/^<p>/, "<p>#{render :badge}")
        html_truncate(text, length: 100)
      end

      def state_classes
        case model.voting_period_status
        when :ongoing
          ["success"]
        when :upcoming
          ["warning"]
        else
          ["muted"]
        end
      end

      def start_date
        return unless model.start_time

        model.start_time.to_date
      end

      def end_date
        return unless model.end_time

        model.end_time.to_date
      end

      def questions_count_status
        content_tag(
          :strong,
          t("decidim.elections.election_m.questions", count: model.questions.count)
        )
      end

      def footer_button_text
        if model.ongoing?
          t("decidim.elections.election_m.footer.vote")
        else
          t("decidim.elections.election_m.footer.view")
        end
      end

      def statuses
        [:questions_count]
      end
    end
  end
end
