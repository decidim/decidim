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

      # REDESIGN_DETAILS: size :m will be deprecated
      def card_size
        case @options[:size]
        when :s
          "decidim/participatory_processes/process_s"
        when :m
          "decidim/participatory_processes/process_m"
        when :l
          "decidim/participatory_processes/process_l"
        else
          "decidim/participatory_processes/process_g"
        end
      end
    end
  end
end
