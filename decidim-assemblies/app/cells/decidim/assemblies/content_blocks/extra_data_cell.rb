# frozen_string_literal: true

module Decidim
  module Assemblies
    module ContentBlocks
      class ExtraDataCell < Decidim::ContentBlocks::ParticipatorySpaceExtraDataCell
        delegate :duration, to: :presented_resource

        private

        def extra_data_items
          [duration_item].compact
        end

        def presented_resource
          Decidim::Assemblies::AssemblyPresenter.new(resource)
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
