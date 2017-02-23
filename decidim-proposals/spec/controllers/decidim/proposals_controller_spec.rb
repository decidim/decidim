# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Proposals
    describe ProposalsController, type: :controller do
      let(:user) { create(:user, :confirmed, organization: feature.organization) }

      routes do
        Decidim::Proposals::Engine.routes
      end

      before do
        @request.env["decidim.current_organization"] = feature.organization
        @request.env["decidim.current_participatory_process"] = feature.participatory_process
        @request.env["decidim.current_feature"] = feature
        sign_in user
      end

      let(:params) do
        {
          feature_id: feature.id,
          participatory_process_id: feature.participatory_process.id
        }
      end

      describe "GET index" do
        context "with votes enabled" do
          let(:feature) do
            create(:proposal_feature, :with_votes_enabled)
          end

          it "shows most_voted option to sort" do
            get :index
            expect(controller.send(:order_fields)).to include(:most_voted)
          end
        end

        context "with votes disabled" do
          let(:feature) do
            create(:proposal_feature)
          end

          it "doesn't show most_voted option to sort" do
            get :index
            expect(controller.send(:order_fields)).not_to include(:most_voted)
          end
        end
      end

      describe "POST create" do
        context "when creation is not enabled" do
          let(:feature) { create(:proposal_feature) }

          it "raises an error" do
            expect(CreateProposal).not_to receive(:call)

            post :create, params: params

            expect(flash[:alert]).not_to be_empty
            expect(response).to have_http_status(302)
          end
        end

        context "when creation is enabled" do
          let(:feature) { create(:proposal_feature, :with_creation_enabled) }

          it "creates a proposal" do
            expect(CreateProposal).to receive(:call)

            post :create, params: params
          end
        end
      end
    end
  end
end
