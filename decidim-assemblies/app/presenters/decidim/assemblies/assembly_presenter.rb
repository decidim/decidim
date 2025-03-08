# frozen_string_literal: true

module Decidim
  module Assemblies
    class AssemblyPresenter < SimpleDelegator
      include Decidim::TranslationsHelper

      def hero_image_url
        assembly.attached_uploader(:hero_image).url
      end

      def banner_image_url
        assembly.attached_uploader(:banner_image).url
      end

      def area_name
        return if assembly.area.blank?

        Decidim::AreaPresenter.new(assembly.area).translated_name_with_type
      end

      def creation_date
        formatted_date(assembly.creation_date)
      end

      def included_at
        formatted_date(assembly.included_at)
      end

      def closing_date
        formatted_date(assembly.closing_date)
      end

      def duration
        return I18n.t("indefinite_duration", scope: "decidim.assemblies.assemblies.description") if (date = assembly.duration).blank?

        formatted_date(date)
      end

      def formatted_date(date)
        return if date.blank?

        I18n.l(date, format: :decidim_short)
      end

      def assembly
        __getobj__
      end
    end
  end
end
