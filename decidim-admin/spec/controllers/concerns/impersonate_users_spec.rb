# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    class ImpersonateFakeController < Decidim::Admin::ApplicationController
      include ImpersonateUsers
    end

    describe ImpersonateFakeController, type: :controller do
      let(:request) do
        ActionController::TestRequest.create(
          Decidim::Admin::ImpersonateFakeController
        )
      end

      let(:organization) { create(:organization) }
      let(:user) { create(:user, :confirmed, :admin, organization: organization) }
      let(:impersonation_log) { create(:impersonation_log, expired_at: nil, ended_at: Time.current, reason: "Test") }
      let(:redirect_url) { "http://localhost:3000/admin/impersonatable_users" }

      describe "#check_impersonation_log_expired" do
        it "returns nil on ajax requests" do
          request.set_header "HTTP_X_REQUESTED_WITH", "XMLHttpRequest"
          request.fetch_header("HTTP_ACCEPT") do |k|
            request.set_header k, [Mime[:js], Mime[:html], Mime[:xml], "text/xml", "*/*"].join(", ")
          end
          allow(controller).to receive(:request).and_return(request)
          expect(controller.send(:check_impersonation_log_expired)).to be_nil
        end

        it "returns nil on non HTML responses" do
          request.set_header "HTTP_ACCEPT", [Mime[:js], Mime[:xml]].join(",")
          allow(controller).to receive(:request).and_return(request)
          expect(controller.send(:check_impersonation_log_expired)).to be_nil
        end

        it "redirects when impersonated session is expired" do
          expect(controller.send(:check_impersonation_log_expired)).to be_nil
          request.set_header "HTTP_ACCEPT", [Mime[:html], "text/html"].join(",")

          allow(controller).to receive(:real_user).and_return(user)
          allow(controller).to receive(:expired_log).and_return(impersonation_log)
          allow(controller).to receive(:redirect_to).and_return(redirect_url)
          expect(controller.send(:check_impersonation_log_expired)).to eq(redirect_url)
        end
      end
    end
  end
end
