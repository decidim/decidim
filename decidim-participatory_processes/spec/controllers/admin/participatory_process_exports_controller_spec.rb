# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryProcesses
    module Admin
      describe ParticipatoryProcessExportsController, type: :controller do
        routes { Decidim::ParticipatoryProcesses::AdminEngine.routes }

        let!(:organization) { create(:organization) }
        let!(:participatory_process) { create :participatory_process, organization: organization }
        let!(:user) { create(:user, :admin, :confirmed, organization: organization) }

        let(:params) do
          {
            id: "participatory_processes",
            participatory_process_slug: participatory_process.slug
          }
        end

        before do
          request.env["decidim.current_organization"] = organization
          sign_in user, scope: :user
        end

        describe "POST create" do
          it "enqueues a job with the default format" do
            expect(ExportParticipatorySpaceJob).to receive(:perform_later)
              .with(user, participatory_process, "participatory_processes", "JSON")

            post(:create, params: params)
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with("export", Decidim::ParticipatoryProcess, user)
              .and_call_original

            expect { post(:create, params: params) }.to change(Decidim::ActionLog, :count)
            action_log = Decidim::ActionLog.last
            expect(action_log.action).to eq("export")
            expect(action_log.version).to be_present
          end
        end
      end
    end
  end
end
