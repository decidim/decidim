# frozen_string_literal: true

module Decidim
  module Assemblies
    module ContentBlocks
      class ExtraDataCell < Decidim::ContentBlocks::ParticipatorySpaceExtraDataCell
        delegate :assembly_type, :duration, to: :presented_resource

        private

        def extra_data_items
          [type_item, duration_item].compact
        end

        def presented_resource
          AssemblyPresenter.new(resource)
        end

        def type_item
          return if assembly_type.blank?

          {
            title: t("assembly_type", scope: "decidim.assemblies.show"),
            icon: "group-2-line",
            text: assembly_type
          }
        end

        def duration_item
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
