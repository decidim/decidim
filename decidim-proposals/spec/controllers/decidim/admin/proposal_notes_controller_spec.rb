# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe ProposalNotesController, type: :controller do
        routes { Decidim::Proposals::AdminEngine.routes }

        let(:proposal) { create(:proposal) }
        let(:feature) { proposal.feature }
        let(:current_user) { create(:user, :confirmed, :admin, organization: feature.organization) }

        let(:params) do
          {
            proposal_id: proposal.id,
            feature_id: feature.id,
            participatory_process_slug: feature.participatory_space.slug
          }
        end

        before do
          request.env["decidim.current_organization"] = feature.organization
          request.env["decidim.current_feature"] = feature
          sign_in current_user
        end

        describe "POST create" do
          context "when the command fails " do
            it "renders the index template" do
              post :create, params: params

              expect(response).to render_template(:index)
            end
          end

          # context "when the command success" do
          #   it "creates a proposal note" do
          #
          #     post :create, params: params
          #     # TODO
          #     expect(response).to redirect_to(decidim_participatory_process_proposals.proposal_proposal_notes_path( feature.id, feature.participatory_space.slug,proposal))
          #   end
          # end
        end
      end
    end
  end
end
