# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe UserSuspensionController, type: :controller do
      routes { Decidim::Admin::Engine.routes }

      let(:organization) { create :organization }
      let(:current_user) { create(:user, :admin, :confirmed, organization: organization) }

      before do
        request.env["decidim.current_organization"] = organization
        sign_in current_user, scope: :user
      end

      describe "unsuspend" do
        let!(:user) { create(:user, :blocked, :confirmed, organization: organization, nickname: "some_nickname") }

        context "when having a user" do
          it "flashes a notice message" do
            delete :destroy, params: { user_id: user.id }

            expect(user.reload.suspended?).to be(false)
          end
        end
      end

      describe "suspend" do
        let!(:user) { create(:user, :confirmed, organization: organization, nickname: "some_nickname") }

        context "when having a user" do
          it "flashes a notice message" do
            put :create, params: { user_id: user.id, justification: ::Faker::Lorem.sentence(word_count: 12) }

            expect(user.reload.suspended?).to be(true)
          end
        end
      end
    end
  end
end
