# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This cell renders a list of processes
    class ProcessesCell < Decidim::ViewModel
      include Decidim::CardHelper

      alias processes model

      def total_count
        @total_count ||= options[:total_count] || processes.size
      end

      def show_all_path
        @show_all_path ||= options[:show_all_path]
      end

      def title
        options[:title] || t("related_processes", scope: "decidim.participatory_processes.show")
      end
    end
  end
end
