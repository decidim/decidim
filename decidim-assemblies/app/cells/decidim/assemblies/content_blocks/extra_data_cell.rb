# frozen_string_literal: true

module Decidim
  module Assemblies
    module ContentBlocks
      class ExtraDataCell < Decidim::ContentBlocks::ParticipatorySpaceExtraDataCell
        delegate :assembly_type, :duration, to: :resource

        private

        def extra_data_items
          [type_item, duration_item].compact
        end

        def type_item
          return if assembly_type.blank?

          {
            title: t("assembly_type", scope: "decidim.assemblies.show"),
            icon: "group-2-line",
            text: translated_attribute(assembly_type.title)
          }
        end

        def duration_item
          text = duration.blank? ? I18n.t("indefinite_duration", scope: "decidim.assemblies.assemblies.description") : I18n.l(duration, format: :decidim_short)

          {
            title: t("duration", scope: "decidim.assemblies.show"),
            icon: "calendar-line",
            text:
          }
        end
      end
    end
  end
end
