# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe NotificationsSubscriptionsController do
    routes { Decidim::Core::Engine.routes }

    let(:organization) { create(:organization) }
    let(:user) { create(:user, :confirmed, organization:) }

    before do
      request.env["devise.mapping"] = ::Devise.mappings[:user]
      request.env["decidim.current_organization"] = organization
      sign_in user
    end

    describe "POST #create" do
      let(:params) do
        {
          endpoint: "https://example.org/subscription",
          keys: {
            auth: "auth_code_121",
            p256dh: "a_p256dh"
          }
        }
      end

      context "when endpoint is supported" do
        let(:params) do
          {
            endpoint: "https://fcm.googleapis.com/fcm/send/abc123",
            keys: {
              auth: "auth_code_121",
              p256dh: "a_p256dh"
            }
          }
        end

        it "returns ok" do
          post(:create, params:)

          expect(response).to have_http_status(:ok)
        end

        it "stores the subscription in user notification settings" do
          post(:create, params:)

          subscriptions = user.reload.notification_settings["subscriptions"]
          expect(subscriptions).to eq(
            "auth_code_121" => {
              "auth" => "auth_code_121",
              "p256dh" => "a_p256dh",
              "endpoint" => "https://fcm.googleapis.com/fcm/send/abc123"
            }
          )
        end
      end

      it "returns unprocessable content when endpoint is not supported" do
        post(:create, params:)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body).to eq(
          "error" => I18n.t("notifications_settings.show.push_notifications_unsupported_browser", scope: "decidim")
        )
        subscriptions = user.reload.notification_settings["subscriptions"]
        expect(subscriptions).to be_nil
      end
    end
  end
end
