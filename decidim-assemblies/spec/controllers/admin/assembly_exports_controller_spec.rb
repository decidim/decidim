# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Assemblies
    module Admin
      describe AssemblyExportsController, type: :controller do
        routes { Decidim::Assemblies::AdminEngine.routes }

        let!(:organization) { create(:organization) }
        let!(:assembly) { create :assembly, organization: }
        let!(:user) { create(:user, :admin, :confirmed, organization:) }

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

            post(:create, params:)
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with("export", assembly, user)
              .and_call_original

            expect { post(:create, params:) }.to change(Decidim::ActionLog, :count)
            action_log = Decidim::ActionLog.last
            expect(action_log.action).to eq("export")
            expect(action_log.version).to be_present
          end
        end
      end
    end
  end
end
