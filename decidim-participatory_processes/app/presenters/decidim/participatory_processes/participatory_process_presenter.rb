# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    class ParticipatoryProcessPresenter < SimpleDelegator
      def hero_image_url
        process.attached_uploader(:hero_image).url(host: process.organization.host)
      end

      def banner_image_url
        process.attached_uploader(:banner_image).url(host: process.organization.host)
      end

      def process
        __getobj__
      end
    end
  end
end
