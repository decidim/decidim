# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    class ParticipatoryProcessGroupPresenter < SimpleDelegator
      def hero_image_url
        return if process_group.blank?

        process_group.attached_uploader(:hero_image).url(host: process_group.organization.host)
      end

      def process_group
        __getobj__
      end
    end
  end
end
