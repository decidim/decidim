# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe ConflictsController, type: :controller do
      routes { Decidim::Admin::Engine.routes }

      let(:organization) do
        create(
          :organization,
          available_authorizations: ["dummy_authorization_handler"]
        )
      end
      let(:current_user) { create(:user, :admin, :confirmed, organization:) }

      before do
        request.env["decidim.current_organization"] = organization
        sign_in current_user, scope: :user
      end

      context "when listing all conflicts" do
        it "renders index template" do
          get :index

          expect(subject).to render_template(:index)
        end
      end

      context "when updating a conflict" do
        let(:organization) { create :organization }
        let(:current_user) { create :user, :confirmed, :admin, organization: }
        let(:new_user) { create :user, :admin, organization:, email: "user@test.com" }
        let(:managed_user) { create :user, managed: true, organization: }
        let(:conflict) do
          Decidim::Verifications::Conflict.create(current_user: new_user, managed_user:)
        end

        it "renders edit template" do
          get :edit, params: { id: conflict.id }

          expect(subject).to render_template(:edit)
        end

        it "Updates conflict" do
          put :update, params: {
            id: conflict.id,
            transfer_user: {
              reason: "For a test",
              email: "user@test.com"
            }
          }

          expect(flash[:notice]).to eq("The current transfer has been successfully completed.")
        end

        it "does not update when conflict is nil" do
          allow(Decidim::Verifications::Conflict)
            .to receive(:find)
            .with(conflict.id.to_s)
            .and_return(nil)

          put :update, params: {
            id: conflict.id,
            transfer_user: {
              reason: "For a test",
              email: "user@test.com"
            }
          }

          expect(flash[:alert]).to eq("There was a problem transfering the current participant to managed participant.")
        end
      end
    end
  end
end
