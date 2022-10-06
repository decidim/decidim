# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe InitiativeVotesController, type: :controller do
      routes { Decidim::Initiatives::Engine.routes }

      let(:organization) { create(:organization) }
      let(:initiative) { create(:initiative, organization:) }

      before do
        request.env["decidim.current_organization"] = organization
      end

      context "when POST create" do
        context "and Authorized users" do
          it "Authorized users can vote" do
            expect do
              sign_in initiative.author, scope: :user
              post :create, params: { initiative_slug: initiative.slug, format: :js }
            end.to change { InitiativesVote.where(initiative:).count }.by(1)
          end
        end

        context "and guest users" do
          it "receives unauthorized response" do
            post :create, params: { initiative_slug: initiative.slug, format: :js }
            expect(response).to have_http_status(:unauthorized)
          end

          it "do not register the vote" do
            expect do
              post :create, params: { initiative_slug: initiative.slug, format: :js }
            end.not_to(change { InitiativesVote.where(initiative:).count })
          end
        end
      end

      context "when destroy" do
        let!(:vote) { create(:initiative_user_vote, initiative:, author: initiative.author) }

        context "and authorized users" do
          it "Authorized users can unvote" do
            expect(vote).not_to be_nil

            expect do
              sign_in initiative.author, scope: :user
              delete :destroy, params: { initiative_slug: initiative.slug, format: :js }
            end.to change { InitiativesVote.where(initiative:).count }.by(-1)
          end
        end

        context "and unvote disabled" do
          let(:initiatives_type) { create(:initiatives_type, :undo_online_signatures_disabled, organization:) }
          let(:scope) { create(:initiatives_type_scope, type: initiatives_type) }
          let(:initiative) { create(:initiative, organization:, scoped_type: scope) }

          it "does not remove the vote" do
            expect do
              sign_in initiative.author, scope: :user
              delete :destroy, params: { initiative_slug: initiative.slug, format: :js }
            end.not_to(change { InitiativesVote.where(initiative:).count })
          end

          it "raises an exception" do
            sign_in initiative.author, scope: :user
            delete :destroy, params: { initiative_slug: initiative.slug, format: :js }
            expect(flash[:alert]).not_to be_empty
            expect(response).to have_http_status(:found)
          end
        end
      end
    end
  end
end
