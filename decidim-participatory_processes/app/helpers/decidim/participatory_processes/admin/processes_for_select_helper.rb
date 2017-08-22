# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # This class contains helpers needed to format ParticipatoryProcesses
      # in order to use them in select forms.
      #
      module ProcessesForSelectHelper
        # Public: A formatted collection of ParticipatoryProcesses to be used
        # in forms.
        #
        # Returns an Array.
        def processes_for_select
          @processes_for_select ||= OrganizationParticipatoryProcesses.new(current_organization).map do |process|
            [
              translated_attribute(process.title),
              process.id
            ]
          end
        end
      end
    end
  end
end
