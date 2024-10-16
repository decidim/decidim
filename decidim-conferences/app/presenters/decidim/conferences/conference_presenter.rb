# frozen_string_literal: true

module Decidim
  module Conferences
    class ConferencePresenter < SimpleDelegator
      def hero_image_url
        conference.attached_uploader(:hero_image).url
      end

      def banner_image_url
        conference.attached_uploader(:banner_image).url
      end

      def conference
        __getobj__
      end
    end
  end
end
