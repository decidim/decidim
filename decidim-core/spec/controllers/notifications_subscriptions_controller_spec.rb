# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe NotificationsSubscriptionsController, type: :controller do
    routes { Decidim::Core::Engine.routes }

    let(:organization) { create(:organization, colors: { "theme" => "#f0f0f0" }) }
    let(:user) { create(:user, organization: organization) }
    let(:valid_params) { { endpoint: "https://example.es", keys: { auth: "some_keys", p256dh: "a_p256dh" } } }

    before do
      request.env["decidim.current_organization"] = organization
      allow(controller).to receive(:current_user) { user }
    end

    describe "POST /subscribe_to_notifications" do
      render_views

      it "returns the notifications_subscription created" do
        expect do
          post :create, params: valid_params
        end.to change { Decidim::NotificationsSubscription.count }.by(1)

        expect(response).to have_http_status(:ok)
      end
    end

    describe "DELETE /unsubscribe_to_notifications" do
      before do
        create(:notifications_subscription, user: user)
      end

      render_views

      it "returns the notifications_subscription created" do
        expect do
          delete :delete_by_user, params: { user_id: user.id }
        end.to change { Decidim::NotificationsSubscription.count }.to(0)

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
