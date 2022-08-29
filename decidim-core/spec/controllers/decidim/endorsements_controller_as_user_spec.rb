# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe EndorsementsController, type: :controller do
    include_context "when in a resource"

    describe "As User" do
      context "when endorsements are enabled" do
        let(:component) { create(:component, :with_endorsements_enabled) }

        it "allows endorsements" do
          expect do
            post :create, format: :js, params:
          end.to change(Endorsement, :count).by(1)

          expect(Endorsement.last.author).to eq(user)
          expect(Endorsement.last.resource).to eq(resource)
        end

        context "when requesting user identities without belonging to any user_group" do
          it "only returns the user identity endorse button" do
            get :identities, params: params

            expect(response).to have_http_status(:ok)
            expect(assigns[:user_verified_groups]).to be_empty
            expect(subject).to render_template("decidim/endorsements/identities")
          end
        end

        context "when requesting user identities while belonging to UNverified user_groups" do
          it "only returns the user identity endorse button" do
            create_list(:user_group, 2, users: [user], organization: user.organization)
            get :identities, params: params

            expect(response).to have_http_status(:ok)
            expect(assigns[:user_verified_groups]).to be_empty
            expect(subject).to render_template("decidim/endorsements/identities")
          end
        end

        context "when requesting user identities while belonging to verified user_groups" do
          it "returns the user's and user_groups's identities for the endorse button" do
            create_list(:user_group, 2, :verified, users: [user], organization: user.organization)
            get :identities, params: params

            expect(response).to have_http_status(:ok)
            expect(assigns[:user_verified_groups]).to eq user.user_groups
            expect(subject).to render_template("decidim/endorsements/identities")
          end
        end
      end

      context "when endorsements are disabled" do
        let(:component) { create(:component, :with_endorsements_disabled) }

        it "does not allow endorsing" do
          expect do
            post :create, format: :js, params:
          end.not_to change(Endorsement, :count)

          expect(flash[:alert]).not_to be_empty
          expect(response).to have_http_status(:found)
        end

        context "when requesting user identities" do
          it "raises exception" do
            get :identities, params: params
            expect(response).to have_http_status(:found)
          end
        end
      end

      context "when endorsements are enabled but endorsements are blocked" do
        let(:component) do
          create(:component, :with_endorsements_enabled, :with_endorsements_blocked)
        end

        it "does not allow endorsing" do
          expect do
            post :create, format: :js, params:
          end.not_to change(Endorsement, :count)

          expect(flash[:alert]).not_to be_empty
          expect(response).to have_http_status(:found)
        end

        context "when requesting user identities" do
          it "does not allow it" do
            get :identities, params: params
            expect(response).to have_http_status(:found)
          end
        end
      end
    end

    describe "As User unendorsing a resource" do
      before do
        create(:endorsement, resource:, author: user)
      end

      context "when endorsements are enabled" do
        let(:component) { create(:component, :with_endorsements_enabled) }

        it "deletes the endorsement" do
          expect do
            delete :destroy, format: :js, params:
          end.to change(Endorsement, :count).by(-1)

          expect(Endorsement.count).to eq(0)
        end
      end

      context "when endorsements are disabled" do
        let(:component) { create(:component, :with_endorsements_disabled) }

        it "does not delete the endorsement" do
          expect do
            delete :destroy, format: :js, params:
          end.not_to change(Endorsement, :count)

          expect(flash[:alert]).not_to be_empty
          expect(response).to have_http_status(:found)
        end
      end
    end
  end
end
