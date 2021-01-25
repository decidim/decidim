# frozen_string_literal: true

module Decidim
  module Votings
    # This cell renders the Medium (:m) voting card
    # for an given instance of a Voting
    class VotingMCell < Decidim::CardMCell
      private

      def has_state?
        false
      end

      # Even though we need to render the badge, we can't do it in the normal
      # way, because the paragraph comes from a user input and contains HTML.
      # This causes the badge and the paragraph to appear in different lines.
      # In order to fix it, check the `description` method.
      def has_badge?
        false
      end

      def badge_name
        text = model.period_status
        return unless text

        I18n.t(text, scope: "decidim.votings.votings_m.badge_name")
      end

      # In order to render the badge inline with the paragraph text we need to
      # find the opening `<p>` tag and include the badge right after it. This
      # makes the layout look good.
      def description
        text = super
        text.gsub!(/^<p>/, "<p>#{render :badge}")
        html_truncate(text, length: 100)
      end

      def resource_path
        Decidim::Votings::Engine.routes.url_helpers.voting_path(model)
      end

      def resource_image_path
        model.banner_image.url
      end

      def has_image?
        model.banner_image.url.present?
      end

      def start_time
        model.start_time
      end

      def end_time
        model.end_time
      end

      def footer_button_text
        "view"
      end
    end
  end
end
