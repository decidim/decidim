# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    class ParticipatoryProcessGroupPresenter < SimpleDelegator
      include Rails.application.routes.mounted_helpers
      include ActionView::Helpers::UrlHelper

      delegate :url, to: :hero_image, prefix: true

      def hero_image_url
        return if process_group.blank?

        URI.join(decidim.root_url(host: process_group.organization.host), process_group.try(:hero_image_url)).to_s
      end

      def process_group
        __getobj__
      end
    end
  end
end
