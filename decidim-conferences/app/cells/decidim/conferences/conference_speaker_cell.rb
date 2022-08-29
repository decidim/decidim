# frozen_string_literal: true

module Decidim
  module Conferences
    # This cell renders the card for an instance of an Conference Speaker
    class ConferenceSpeakerCell < Decidim::AuthorCell
      include Decidim::Meetings::MeetingCellsHelper
      include Cell::ViewModel::Partial
      include Decidim::Conferences::Engine.routes.url_helpers
      property :name
      property :nickname
      property :profile_path

      def show
        render
      end

      def speakers_list
        cell(
          "decidim/collapsible_list",
          presenters_for_speakers(list),
          cell_name: "decidim/author",
          cell_options: options.merge(has_actions: false),
          size:
        )
      end

      private

      def list
        @options[:list]
      end

      def size
        @options[:size]
      end

      def presenters_for_speakers(speakers)
        speakers.map { |speaker| present(speaker) }
      end

      def avatar_path
        return Decidim::UserPresenter.new(model.user).avatar_url if model.user.present?

        Decidim::ConferenceSpeakerPresenter.new(model).avatar_url
      end

      def has_profile?
        model.profile_path.present?
      end

      def position
        translated_attribute model.position
      end

      def affiliation
        translated_attribute model.affiliation
      end

      def short_bio
        return unless model.short_bio.presence

        translated_attribute model.short_bio
      end

      def twitter_handle
        return unless model.twitter_handle.presence

        link_to t(".go_to_twitter"), "https://twitter.com/#{model.twitter_handle}", target: "_blank", rel: "noopener"
      end

      def personal_url
        return unless model.personal_url.presence || (model.user.presence && model.user.personal_url.presence)

        link_to t(".personal_website"), model.personal_url || model.user.personal_url, target: "_blank", class: "card-link", rel: "noopener"
      end

      def meetings
        model.conference_meetings
      end

      def meeting_title(meeting)
        meeting = meeting.becomes(Decidim::Meetings::Meeting)
        link_to present(meeting).title, resource_locator(meeting).path
      end
    end
  end
end
