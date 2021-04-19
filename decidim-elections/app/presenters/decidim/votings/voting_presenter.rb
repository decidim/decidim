# frozen_string_literal: true

module Decidim
  module Votings
    class VotingPresenter < SimpleDelegator
      include Rails.application.routes.mounted_helpers
      include ActionView::Helpers::UrlHelper
      include Decidim::SanitizeHelper
      include Decidim::TranslatableAttributes

      delegate :url, to: :introductory_image, prefix: true
      delegate :url, to: :banner_image, prefix: true

      def title
        content = translated_attribute(voting.title)
        decidim_html_escape(content)
      end

      def introductory_image_url
        return if voting.introductory_image.blank?

        URI.join(decidim.root_url(host: voting.organization.host), voting.introductory_image_url).to_s
      end

      def banner_image_url
        return if voting.banner_image.blank?

        URI.join(decidim.root_url(host: voting.organization.host), voting.banner_image_url).to_s
      end

      def voting
        __getobj__
      end
    end
  end
end
