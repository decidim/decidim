# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This cell renders the process card for an instance of a Process
    # the default size is the Medium Card (:m)
    class ProcessCell < Decidim::ViewModel
      def show
        cell card_size, model, options
      end

      private

      def card_size
        "decidim/participatory_processes/process_m"
      end
    end
  end
end
