# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryProcesses
    module Admin
      describe ExportsController, type: :controller do
        routes { Decidim::ParticipatoryProcesses::AdminEngine.routes }

        let!(:organization) { create(:organization) }
        let!(:participatory_process) { create(:participatory_process, organization:) }
        let!(:user) { create(:user, :admin, :confirmed, organization:) }
        let!(:component) { create(:component, participatory_space: participatory_process, manifest_name: "dummy") }

        let(:params) do
          {
            id: "dummies",
            component_id: component.id,
            participatory_process_slug: participatory_process.slug
          }
        end

        before do
          request.env["decidim.current_organization"] = organization
          sign_in user, scope: :user
        end

        describe "POST create" do
          context "when a format is provided" do
            it "enqueues a job with the provided format" do
              params[:format] = "csv"

              expect(ExportJob).to receive(:perform_later)
                .with(user, component, "dummies", "csv", nil)

              post(:create, params:)
            end
          end

          context "when a format is not provided" do
            it "enqueues a job with the default format" do
              expect(ExportJob).to receive(:perform_later)
                .with(user, component, "dummies", "json", nil)

              post(:create, params:)
            end
          end
        end

        it "traces the action", versioning: true do
          expect(Decidim.traceability)
            .to receive(:perform_action!)
            .with("export_component", component, user, { name: "dummies", format: "json" })
            .and_call_original

          expect { post(:create, params:) }.to change(Decidim::ActionLog, :count)
          action_log = Decidim::ActionLog.last
          expect(action_log.action).to eq("export_component")
          expect(action_log.version).to be_present
        end
      end
    end
  end
end
