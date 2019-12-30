# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    class ParticipatoryProcessPresenter < SimpleDelegator
      include Rails.application.routes.mounted_helpers
      include ActionView::Helpers::UrlHelper

      delegate :url, to: :hero_image, prefix: true
      delegate :url, to: :banner_image, prefix: true

      def hero_image_url
        URI.join(decidim.root_url(host: process.organization.host), process.hero_image_url).to_s
      end

      def banner_image_url
        URI.join(decidim.root_url(host: process.organization.host), process.banner_image_url).to_s
      end

      def process
        __getobj__
      end
    end
  end
end
