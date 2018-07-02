# frozen_string_literal: true

module Decidim
  module Conferences
    # This cell renders the card for an instance of an Conference Speaker
    class ConferenceSpeakerCell < Decidim::AuthorCell
      property :name
      property :nickname
      property :profile_url
      property :avatar

      private

      def has_profile?
        model.profile_url.present?
      end

      def charge
        translated_attribute model.charge
      end

      def affiliation
        translated_attribute model.affiliation
      end

      def short_bio
        translated_attribute model.short_bio
      end

      def twitter_handle
        link_to "@#{model.twitter_handle}", "https://twitter.com/#{model.twitter_handle}", target: "_blank"
      end

      def personal_url
        link_to (model.personal_url || model.user.personal_url).to_s, model.personal_url || model.user.personal_url, target: "_blank"
      end
    end
  end
end
