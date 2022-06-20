# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe NotificationsSubscriptionsPersistor, type: :service do
    subject { described_class.new(user) }

    let(:organization) { create(:organization, colors: { "theme" => "#f0f0f0" }) }
    let(:params) { { endpoint: "https://example.es", keys: { auth: "auth_code_121", p256dh: "a_p256dh" } } }

    describe "#add_subscription" do
      context "when no subscriptions" do
        let(:user) { create(:user, organization: organization) }

        it "persist subscription params" do
          expect(subject.add_subscription(params)).to be_truthy
          expect(user.notifications_subscriptions).not_to be_empty
          expect(user.notifications_subscriptions["auth_code_121"]["endpoint"]).to eq(params[:endpoint])
          expect(user.notifications_subscriptions["auth_code_121"]["auth"]).to eq(params[:keys][:auth])
          expect(user.notifications_subscriptions["auth_code_121"]["p256dh"]).to eq(params[:keys][:p256dh])
        end
      end

      context "when user has subscriptions" do
        let(:user) do
          create(:user, organization: organization, "notification_settings" => {
                   "subscriptions" => {
                     "auth_code_100" => { p256dh: "value", endpoint: "value" }
                   }
                 })
        end

        it "persist subscription params" do
          expect(subject.add_subscription(params)).to be_truthy
          expect(user.notifications_subscriptions.size).to eq(2)
          expect(user.notifications_subscriptions["auth_code_121"]["endpoint"]).to eq(params[:endpoint])
          expect(user.notifications_subscriptions["auth_code_121"]["auth"]).to eq(params[:keys][:auth])
          expect(user.notifications_subscriptions["auth_code_121"]["p256dh"]).to eq(params[:keys][:p256dh])
        end
      end
    end

    describe "#delete_subscription" do
      let(:user) do
        create(:user, organization: organization, "notification_settings" => {
                 "subscriptions" => {
                   "auth_code_121" => { p256dh: "value", endpoint: "value" },
                   "auth_code_100" => { p256dh: "value", endpoint: "value" }
                 }
               })
      end

      it "returns the result of the subscription deletion" do
        expect(subject.delete_subscription("auth_code_121")).to be_truthy
        expect(user.notifications_subscriptions).not_to be_empty
        expect(user.notifications_subscriptions["auth_code_121"]).to be_nil
        expect(user.notifications_subscriptions["auth_code_100"]).to be_present
      end
    end
  end
end
