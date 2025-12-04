# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    class ParticipatoryProcessPresenter < ResourcePresenter
      include Decidim::ResourceHelper
      include ActionView::Helpers::UrlHelper

      def hero_image_url
        process.attached_uploader(:hero_image).url
      end

      def area_name
        return if process.area.blank?

        Decidim::AreaPresenter.new(process.area).translated_name_with_type
      end

      def process
        __getobj__
      end
    end
  end
end
