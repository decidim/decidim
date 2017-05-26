# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe ExportsController, type: :controller do
      let!(:organization) { create(:organization) }
      let!(:participatory_process) { create :participatory_process, organization: organization }
      let!(:user) { create(:user, :admin, :confirmed, organization: organization) }
      let!(:feature) { create(:feature, participatory_process: participatory_process, manifest_name: "dummy") }

      before do
        @request.env["decidim.current_organization"] = organization
        sign_in user, scope: :user
      end

      let(:params) do
        {
          id: "dummies",
          feature_id: feature.id,
          participatory_process_id: participatory_process.id
        }
      end

      describe "POST create" do
        context "when a format is provided" do
          it "enqueues a job with the provided format" do
            params[:format] = "csv"

            expect(ExportJob).to receive(:perform_later)
              .with(user, feature, "dummies", "csv")

            post(:create, params: params)
          end
        end

        context "when a format is not provided" do
          it "enqueues a job with the default format" do
            expect(ExportJob).to receive(:perform_later)
              .with(user, feature, "dummies", "json")

            post(:create, params: params)
          end
        end
      end
    end
  end
end
