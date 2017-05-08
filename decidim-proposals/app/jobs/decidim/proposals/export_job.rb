module Decidim
  module Proposals
    class ExportJob < ApplicationJob
      queue_as :default

      def perform(user, feature, format)
        proposals = Proposal
          .where(feature: feature)
          .includes(:category, feature: { participatory_process: :organization })

        export_data = Decidim::Exporters.const_get(format.upcase)
                        .new(proposals, ProposalSerializer).export

        name = "proposals-#{I18n.localize(DateTime.now.to_date, format: :default)}-#{Time.now.seconds_since_midnight.to_i}"

        ExportMailer.export(user, name, export_data).deliver_now
      end
    end
  end
end
