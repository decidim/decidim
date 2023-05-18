# frozen_string_literal: true

module Decidim
  module Assemblies
    module ContentBlocks
      class ExtraDataCell < Decidim::ContentBlocks::ParticipatorySpaceExtraDataCell
        delegate :meta_scope, :duration, to: :resource

        private

        def extra_data_items
          [type_item, duration_item].compact
        end

        def type_item
          {
            title: t("assembly_type", scope: "decidim.assemblies.show"),
            icon: "group-2-line",
            text: translated_attribute(meta_scope)
          }
        end

        def duration_item
          return if duration.blank?

          {
            title: t("duration", scope: "decidim.assemblies.show"),
            icon: "calendar-line",
            text: duration
          }
        end
      end
    end
  end
end
