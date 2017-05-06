# frozen_string_literal: true
module Decidim
  module Proposals
    module Admin
      # This controller allows admins to manage proposals in a participatory process.
      class ExportsController < Admin::ApplicationController
        def create
          # call the new proposal export command
          authorize! :read, Proposal
          authorize! :export, Proposal

          respond_to do |format|
            format.csv do
              exporter = Decidim::Exporters::CSV.new(proposals, ProposalSerializer)

              send_data ExportNotifier.new("proposals", exporter).notify,
                        type: "application/zip",
                        disposition: "attachment",
                        filename: "zipfile.zip"
            end

            format.json do |format|
              send_data Decidim::Exporters::JSON.new(proposals, ProposalSerializer).export.data,
                        type: "application/json",
                        disposition: "attachment",
                        filename: "#{filename}.json"
            end
          end
        end

        private

        def proposals
          Proposal
            .where(feature: current_feature)
            .includes(:category, feature: { participatory_process: :organization })
        end
      end
    end
  end
end
