# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Assemblies
    module Admin
      describe ImportsController, type: :controller do
        routes { Decidim::Assemblies::AdminEngine.routes }

        it_behaves_like "admin imports controller" do
          let!(:participatory_space) { create :assembly, organization: }
          let(:extra_params) { { assembly_slug: participatory_space.slug } }
          let(:file) { upload_test_file(Decidim::Dev.test_file("import_proposals.csv", "text/csv")) }
        end
      end
    end
  end
end
