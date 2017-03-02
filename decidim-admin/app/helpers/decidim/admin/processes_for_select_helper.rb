module Decidim
  module Admin
    module ProcessesForSelectHelper

      def processes_for_select
        @processes_for_select ||= current_organization.participatory_processes.map do |process|
          [
            translated_attribute(process.title),
            process.id
          ]
        end
      end
    end
  end
end
