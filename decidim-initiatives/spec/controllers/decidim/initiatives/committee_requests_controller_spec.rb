# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe CommitteeRequestsController, type: :controller do
      routes { Decidim::Initiatives::Engine.routes }

      let(:organization) { create(:organization) }
      let!(:initiative) { create(:initiative, :created, organization:) }
      let(:admin_user) { create(:user, :admin, :confirmed, organization:) }
      let(:user) { create(:user, :confirmed, organization:) }

      before do
        request.env["decidim.current_organization"] = organization
      end

      context "when GET spawn" do
        let(:user) { create(:user, :confirmed, organization:) }

        before do
          create(:authorization, user:)
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
            end.not_to change(InitiativesCommitteeMember, :count)
          end
        end

        context "and published initiative" do
          let!(:published_initiative) { create(:initiative, :published, organization:) }

          it "Membership request is not created" do
            expect do
              get :spawn, params: { initiative_slug: published_initiative.slug }
            end.not_to change(InitiativesCommitteeMember, :count)
          end
        end
      end

      context "when GET approve" do
        let(:membership_request) { create(:initiatives_committee_member, initiative:, state: "requested") }

        context "and Owner" do
          before do
            sign_in initiative.author, scope: :user
          end

          it "request gets approved" do
            get :approve, params: { initiative_slug: membership_request.initiative.to_param, id: membership_request.to_param }
            membership_request.reload
            expect(membership_request).to be_accepted
          end
        end

        context "and other users" do
          let(:user) { create(:user, :confirmed, organization:) }

          before do
            create(:authorization, user:)
            sign_in user, scope: :user
          end

          it "Action is denied" do
            get :approve, params: { initiative_slug: membership_request.initiative.to_param, id: membership_request.to_param }
            expect(flash[:alert]).not_to be_empty
            expect(response).to have_http_status(:found)
          end
        end

        context "and Admin" do
          before do
            sign_in admin_user, scope: :user
          end

          it "request gets approved" do
            get :approve, params: { initiative_slug: membership_request.initiative.to_param, id: membership_request.to_param }
            membership_request.reload
            expect(membership_request).to be_accepted
          end
        end
      end

      context "when DELETE revoke" do
        let(:membership_request) { create(:initiatives_committee_member, initiative:, state: "requested") }

        context "and Owner" do
          before do
            sign_in initiative.author, scope: :user
          end

          it "request gets approved" do
            delete :revoke, params: { initiative_slug: membership_request.initiative.to_param, id: membership_request.to_param }
            membership_request.reload
            expect(membership_request).to be_rejected
          end
        end

        context "and Other users" do
          let(:user) { create(:user, :confirmed, organization:) }

          before do
            create(:authorization, user:)
            sign_in user, scope: :user
          end

          it "Action is denied" do
            delete :revoke, params: { initiative_slug: membership_request.initiative.to_param, id: membership_request.to_param }
            expect(flash[:alert]).not_to be_empty
            expect(response).to have_http_status(:found)
          end
        end

        context "and Admin" do
          before do
            sign_in admin_user, scope: :user
          end

          it "request gets approved" do
            delete :revoke, params: { initiative_slug: membership_request.initiative.to_param, id: membership_request.to_param }
            membership_request.reload
            expect(membership_request).to be_rejected
          end
        end
      end
    end
  end
end
