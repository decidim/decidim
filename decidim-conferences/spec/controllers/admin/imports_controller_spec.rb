# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Conferences
    module Admin
      describe ImportsController, type: :controller do
        routes { Decidim::Conferences::AdminEngine.routes }

        it_behaves_like "admin imports controller" do
          let!(:participatory_space) { create :conference, organization: }
          let(:extra_params) { { conference_slug: participatory_space.slug } }

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
