# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe EndorsementsController, type: :controller do
    include_context "when in a resource"

    #
    # As Organization
    #
    describe "As Organization" do
      let(:user_group) { create(:user_group, verified_at: Time.current) }

      before do
        create(:user_group_membership, user:, user_group:)
        params[:user_group_id] = user_group.id
      end

      describe "endorsing a resource" do
        context "when endorsements are enabled" do
          let(:component) do
            create(:dummy_component, :with_endorsements_enabled)
          end

          it "allows endorsing" do
            expect do
              post :create, format: :js, params:
            end.to change(Endorsement, :count).by(1)

            expect(Endorsement.last.author).to eq(user)
            expect(Endorsement.last.resource).to eq(resource)
            expect(Endorsement.last.user_group).to eq(user_group)
          end
        end

        context "when endorsements are disabled" do
          let(:component) do
            create(:dummy_component, :with_endorsements_disabled)
          end

          it "does not allow endorsing" do
            expect do
              post :create, format: :js, params:
            end.not_to change(Endorsement, :count)

            expect(flash[:alert]).not_to be_empty
            expect(response).to have_http_status(:found)
          end
        end

        context "when endorsements are enabled but endorsements are blocked" do
          let(:component) do
            create(:dummy_component, :with_endorsements_enabled, :with_endorsements_blocked)
          end

          it "does not allow endorsing" do
            expect do
              post :create, format: :js, params:
            end.not_to change(Endorsement, :count)

            expect(flash[:alert]).not_to be_empty
            expect(response).to have_http_status(:found)
          end
        end
      end

      describe "As User unendorsing a resource" do
        before do
          create(:endorsement, resource:, author: user, user_group:)
        end

        context "when endorsements are enabled" do
          let(:component) do
            create(:dummy_component, :with_endorsements_enabled)
          end

          it "deletes the endorsement" do
            expect do
              delete :destroy, format: :js, params:
            end.to change(Endorsement, :count).by(-1)

            expect(Endorsement.count).to eq(0)
          end
        end

        context "when endorsements are disabled" do
          let(:component) do
            create(:dummy_component, :with_endorsements_disabled)
          end

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
end
