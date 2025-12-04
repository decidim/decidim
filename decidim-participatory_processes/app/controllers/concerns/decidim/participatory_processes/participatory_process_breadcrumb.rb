# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module ParticipatoryProcessBreadcrumb
      extend ActiveSupport::Concern

      private

      def current_participatory_space_breadcrumb_item
        return {} if current_participatory_space.blank?
        return super unless current_participatory_space.is_a?(Decidim::ParticipatoryProcess)

        items = []

        if current_participatory_space.participatory_process_group.present?
          items << {
            label: translated_attribute(current_participatory_space.participatory_process_group.title),
            active: false,
            url: decidim_participatory_processes.participatory_process_group_path(current_participatory_space.participatory_process_group, locale: current_locale),
            resource: current_participatory_space.participatory_process_group
          }
        end

        items << super
      end
    end
  end
end
