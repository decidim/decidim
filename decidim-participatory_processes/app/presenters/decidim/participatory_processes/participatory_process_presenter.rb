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

      def area_name
        return if process.area.blank?

        Decidim::AreaPresenter.new(process.area).translated_name_with_type
      end

      def date_range
        dates = [process.start_date, process.end_date]
        return if dates.all?(&:blank?)

        dates.map! do |date|
          date.blank? ? "-" : I18n.l(date, format: :decidim_short_dashed)
        end

        dates.join(" / ")
      end

      def process
        __getobj__
      end
    end
  end
end
