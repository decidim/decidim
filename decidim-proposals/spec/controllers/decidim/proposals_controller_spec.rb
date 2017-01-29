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

      describe "POST create" do
        context "when creation is not enabled" do
          let(:feature) { create(:proposal_feature) }

          it "raises an error" do
            expect(CreateProposal).not_to receive(:call)

            expect do
              post :create, params: params
            end.to raise_error RuntimeError, "Proposal creation is not enabled"
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
