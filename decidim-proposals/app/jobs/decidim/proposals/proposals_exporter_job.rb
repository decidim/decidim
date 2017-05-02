module Decidim
  module Proposals
    class ProposalsExporterJob < ApplicationJob
      queue_as :default

      def perform(participatory_process)
        csv = ProposalExporter.new(participatory_process).export
        # upload shit to s3 
      end
    end
  end
end
