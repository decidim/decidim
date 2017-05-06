module Decidim
  module Proposals
    class ProposalsExporterJob < ApplicationJob
      queue_as :default

      def perform(feature, format)
        proposals = Proposal
          .where(feature: current_feature)
          .includes(:category, feature: { participatory_process: :organization })

        export_data = Decidim::Exporters.const_get(format.upcase).new(proposals, ProposalSerializer).export
      end
    end
  end
end
