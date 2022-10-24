# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryProcesses
    module Admin
      describe ImportsController, type: :controller do
        routes { Decidim::ParticipatoryProcesses::AdminEngine.routes }

        it_behaves_like "admin imports controller" do
          let!(:participatory_space) { create :participatory_process, organization: }
          let(:extra_params) { { participatory_process_slug: participatory_space.slug } }

          let(:file) do
            Rack::Test::UploadedFile.new(
              Decidim::Dev.test_file("import_proposals.csv", "text/csv"),
              "text/csv"
            )
          end
        end
      end
    end
  end
end
