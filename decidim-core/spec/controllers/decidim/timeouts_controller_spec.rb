# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe TimeoutsController, type: :controller do
    routes { Decidim::Core::Engine.routes }

    let(:current_user) { create(:user, :confirmed, organization:) }
    let(:timeout_time) { 30.minutes }
    let(:last_request) { (Time.current - time_since_last_request).to_i }
    let(:user_session) { { "last_request_at" => last_request } }
    let(:time_since_last_request) { 1.minute }
    let(:params) { {} }
    let(:max_delay) { 5 }

    before do
      allow(Devise).to receive(:timeout_in).and_return(timeout_time)
      allow(controller).to receive(:user_session).and_return(user_session)
    end

    describe "#seconds_until_timeout" do
      let(:parsed_response) { JSON.parse(response.body) }

      context "when forcing users to authenticate before access organization" do
        let(:organization) { create(:organization, force_users_to_authenticate_before_access_organization: true) }

        before do
          request.env["decidim.current_organization"] = organization
          sign_in current_user, scope: :user
        end

        it "returns seconds until timeout" do
          expect(controller).not_to receive(:store_current_location)

          get :seconds_until_timeout, format: :json, params: params

          expect(response.status).to eq(200)
          expect(parsed_response["seconds_remaining"])
            .to be_between(timeout_time.to_i - time_since_last_request.to_i - max_delay, timeout_time.to_i - time_since_last_request.to_i)
        end
      end
    end
  end
end
