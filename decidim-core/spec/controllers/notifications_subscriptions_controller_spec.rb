# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe NotificationsSubscriptionsController, type: :controller do
    routes { Decidim::Core::Engine.routes }

    describe "POST /notifications_subscriptions" do
      it "returns the status of the request" do
        expect(response).to have_http_status(:ok)
      end
    end

    describe "DELETE /notifications_subscriptions/:auth" do
      it "returns the status of the request" do
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
