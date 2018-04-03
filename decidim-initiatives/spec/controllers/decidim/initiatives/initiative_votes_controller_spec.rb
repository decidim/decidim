# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe InitiativeVotesController, type: :controller do
      routes { Decidim::Initiatives::Engine.routes }

      let(:organization) { create(:organization) }
      let(:initiative) { create(:initiative, organization: organization) }

      before do
        request.env["decidim.current_organization"] = organization
      end

      context "when POST create" do
        context "and Authorized users" do
          it "Authorized users can vote" do
            expect do
              sign_in initiative.author, scope: :user
              post :create, params: { initiative_slug: initiative.slug, format: :js }
            end.to change { InitiativesVote.where(initiative: initiative).count }.by(1)
          end
        end

        context "and Non authorized users" do
          let(:user) { create(:user, :confirmed) }

          it "raise an exception" do
            sign_in user, scope: :user
            post :create, params: { initiative_slug: initiative.slug, format: :js }
            expect(flash[:alert]).not_to be_empty
            expect(response).to have_http_status(302)
          end

          it "do not register the vote" do
            expect do
              sign_in user, scope: :user
              post :create, params: { initiative_slug: initiative.slug, format: :js }
            end.not_to(change { InitiativesVote.where(initiative: initiative).count })
          end
        end

        context "and Guest users" do
          it "receives unauthorized response" do
            post :create, params: { initiative_slug: initiative.slug, format: :js }
            expect(response).to have_http_status(401)
          end

          it "do not register the vote" do
            expect do
              post :create, params: { initiative_slug: initiative.slug, format: :js }
            end.not_to(change { InitiativesVote.where(initiative: initiative).count })
          end
        end
      end

      context "when destroy" do
        let!(:vote) { create(:initiative_user_vote, initiative: initiative, author: initiative.author) }

        context "and authorized users" do
          it "Authorized users can unvote" do
            expect(vote).not_to be_nil

            expect do
              sign_in initiative.author, scope: :user
              delete :destroy, params: { initiative_slug: initiative.slug, format: :js }
            end.to change { InitiativesVote.where(initiative: initiative).count }.by(-1)
          end
        end
      end
    end
  end
end
