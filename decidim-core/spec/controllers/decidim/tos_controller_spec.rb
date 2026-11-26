# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe TosController do
    routes { Decidim::Core::Engine.routes }

    let(:organization) { create(:organization) }
    let(:user) { create(:user, :confirmed, organization:) }

    before do
      request.env["decidim.current_organization"] = organization
    end

    describe "PUT accept_tos" do
      context "when the user is signed in" do
        before { sign_in user }

        it "accepts the terms of service" do
          put :accept_tos
          expect(response).to have_http_status(:found)
          expect(user.reload.tos_accepted?).to be(true)
        end
      end

      context "when the user is not signed in" do
        it "is not allowed" do
          put :accept_tos
          expect(response).to have_http_status(:found)
        end
      end
    end
  end
end
