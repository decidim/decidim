# frozen_string_literal: true

module Decidim
  module ParticipatoryProcessGroups
    class ContentBlockCell < Decidim::ViewModel
      include Decidim::IconHelper

      delegate :public_name_key, :has_settings?, to: :model

      def manifest_name
        model.try(:manifest_name) || model.name
      end

      def participatory_process_group
        controller.send(:participatory_process_group)
      end

      def decidim_participatory_processes
        Decidim::ParticipatoryProcesses::AdminEngine.routes.url_helpers
      end
    end
  end
end
