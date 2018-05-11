# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This cell renders the process card for an instance of a ProcessGroup
    # the default size is the Medium Card (:m)
    class ProcessGroupCell < Decidim::ViewModel
      def show
        cell card_size, model
      end

      private

      def card_size
        "decidim/participatory_processes/process_group_m"
      end
    end
  end
end
