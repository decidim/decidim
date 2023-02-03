# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This cell renders the process card for an instance of a ProcessGroup
    # the default size is the Medium Card (:m)
    class ProcessGroupCell < Decidim::ViewModel
      def show
        cell card_size, model, options
      end

      private

      # REDESIGN_DETAILS: size :m will be deprecated
      def card_size
        case @options[:size]
        when :s
          "decidim/participatory_processes/process_group_s"
        when :g
          "decidim/participatory_processes/process_group_g"
        else
          "decidim/participatory_processes/process_group_m"
        end
      end
    end
  end
end
