# frozen_string_literal: true

module Decidim
  module Consultations
    # This cell renders the Medium (:m) question card
    # for an given instance of a Question
    class ConsultationMCell < Decidim::CardMCell
      private

      def has_state?
        true
      end

      def state_classes
        state_data[:state_classes]
      end

      # Even though we need to render the badge, we can't do it in the normal
      # way, because the paragraph comes from a user input and contains HTML.
      # This causes the badge and the paragraph to appear in different lines.
      # In order to fix it, check the `description` method.
      def has_badge?
        false
      end

      def badge_name
        text = state_data[:badge_name]
        return unless text

        I18n.t(text, scope: "decidim.consultations.show.badge_name")
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
        Decidim::Consultations::Engine.routes.url_helpers.consultation_path(model)
      end

      def resource_image_path
        model.banner_image.url
      end

      def has_image?
        true
      end

      def start_date
        model.start_voting_date
      end

      def end_date
        model.end_voting_date
      end

      def statuses
        super << :questions_count
      end

      def questions_count_status
        # rubocop: disable Style/StringConcatenation
        content_tag(
          :strong,
          t("activemodel.attributes.consultation.questions")
        ) + " " + model.questions.count.to_s
        # rubocop: enable Style/StringConcatenation
      end

      def footer_button_text
        state_data[:button_text]
      end

      # Internal: Calculates and caches the data related to the state of the
      # current consultation.
      def state_data
        @state_data ||= if model.active?
                          { state: :active, badge_name: "open_votes", state_classes: ["success"], button_text: "vote" }
                        elsif model.upcoming?
                          { state: :upcoming, badge_name: "open", state_classes: ["warning"], button_text: "debate" }
                        elsif model.finished?
                          { state: :finished, badge_name: "finished", state_classes: ["muted"], button_text: "view" }
                        elsif model.published_results?
                          { state: :published_results, badge_name: "published_results", state_classes: ["muted"], button_text: "view_results" }
                        else
                          { state: :undefined, badge_name: nil, state_classes: ["muted"], button_text: "view" }
                        end
      end
    end
  end
end
