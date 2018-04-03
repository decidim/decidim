# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe CommitteeRequestsController, type: :controller do
      routes { Decidim::Initiatives::Engine.routes }

      let(:organization) { create(:organization) }
      let!(:initiative) { create(:initiative, :created, organization: organization) }

      before do
        request.env["decidim.current_organization"] = organization
      end

      context "when GET spawn" do
        let(:user) { create(:user, :confirmed, organization: organization) }

        before do
          create(:authorization, user: user)
          sign_in user, scope: :user
        end

        context "and created initiative" do
          it "Membership request is created" do
            expect do
              get :spawn, params: { initiative_slug: initiative.slug }
            end.to change(InitiativesCommitteeMember, :count).by(1)
          end

          it "Duplicated requests finish with an error" do
            expect do
              get :spawn, params: { initiative_slug: initiative.slug }
            end.to change(InitiativesCommitteeMember, :count).by(1)

            expect do
              get :spawn, params: { initiative_slug: initiative.slug }
            end.to change(InitiativesCommitteeMember, :count).by(0)
          end
        end

        context "and published initiative" do
          let!(:published_initiative) { create(:initiative) }

          it "Membership request is not created" do
            expect do
              get :spawn, params: { initiative_slug: published_initiative.slug }
            end.to change(InitiativesCommitteeMember, :count).by(0)
          end
        end
      end
    end
  end
end
