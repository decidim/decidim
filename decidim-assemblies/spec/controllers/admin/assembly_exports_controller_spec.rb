# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Assemblies
    module Admin
      describe AssemblyExportsController, type: :controller do
        routes { Decidim::Assemblies::AdminEngine.routes }

        let!(:organization) { create(:organization) }
        let!(:assembly) { create :assembly, organization: organization }
        let!(:user) { create(:user, :admin, :confirmed, organization: organization) }

        let(:params) do
          {
            id: "assemblies",
            assembly_slug: assembly.slug
          }
        end

        before do
          request.env["decidim.current_organization"] = organization
          sign_in user, scope: :user
        end

        describe "POST create" do
          it "enqueues a job with the default format" do
            expect(ExportParticipatorySpaceJob).to receive(:perform_later)
              .with(user, assembly, "assemblies", "JSON")

            post(:create, params: params)
          end
        end
      end
    end
  end
end
