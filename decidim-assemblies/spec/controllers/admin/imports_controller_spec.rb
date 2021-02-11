# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Assemblies
    module Admin
      describe ImportsController, type: :controller do
        routes { Decidim::Assemblies::AdminEngine.routes }

        let!(:organization) { create(:organization) }
        let!(:assembly) { create :assembly, organization: organization }
        let!(:user) { create(:user, :admin, :confirmed, organization: organization) }
        let!(:component) { create(:component, participatory_space: assembly, manifest_name: "dummy") }
        let(:creator) { Decidim::Admin::Import::Creator.new({ id: 1, "title/en": "My title for abstract creator" }) }

        let(:file) do
          Rack::Test::UploadedFile.new(
            Decidim::Dev.test_file("import_proposals.csv", "text/csv"),
            "text/csv"
          )
        end

        let(:params) do
          {
            file: file,
            component_id: component.id,
            assembly_slug: assembly.slug,
            creator: "Decidim::Admin::Import::Creator"
          }
        end

        before do
          request.env["decidim.current_organization"] = organization
          sign_in user, scope: :user
        end

        describe "POST create with abstract creator" do
          it "raises NotImplementedError" do
            expect do
              post(:create, params: params)
            end.to raise_error(NotImplementedError)
          end
        end
      end
    end
  end
end
