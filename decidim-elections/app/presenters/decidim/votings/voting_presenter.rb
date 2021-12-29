# frozen_string_literal: true

module Decidim
  module Votings
    class VotingPresenter < SimpleDelegator
      include Decidim::SanitizeHelper
      include Decidim::TranslatableAttributes

      def title
        content = translated_attribute(voting.title)
        decidim_html_escape(content)
      end

      def introductory_image_url
        voting.attached_uploader(:introductory_image).url(host: voting.organization.host)
      end

      def banner_image_url
        voting.attached_uploader(:banner_image).url(host: voting.organization.host)
      end

      def voting
        __getobj__
      end
    end
  end
end
