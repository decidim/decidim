# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe EndorsementsController do
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
