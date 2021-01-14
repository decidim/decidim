# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe BlockUserController, type: :controller do
      routes { Decidim::Admin::Engine.routes }

      let(:organization) { create :organization }
      let(:current_user) { create(:user, :admin, :confirmed, organization: organization) }

      before do
        request.env["decidim.current_organization"] = organization
        sign_in current_user, scope: :user
      end

      describe "unblock" do
        let!(:user) { create(:user, :blocked, :confirmed, organization: organization, nickname: "some_nickname") }

        context "when having a user" do
          it "flashes a notice message" do
            delete :destroy, params: { user_id: user.id }

            expect(flash[:notice]).to be_present
            expect(user.reload.blocked?).to be(false)
          end
        end

        context "when the user is not blocked" do
          before do
            user.blocked = false
            user.save!
          end

          it "flashes an alert message" do
            delete :destroy, params: { user_id: user.id }

            expect(flash[:alert]).to be_present
            expect(user.reload.blocked?).to be(false)
          end
        end

        context "when current user is not an admin" do
          before do
            current_user.admin = false
            current_user.save!
          end

          it "the user remains blocked" do
            delete :destroy, params: { user_id: user.id }

            expect(user.reload.blocked?).to be(true)
          end
        end
      end

      describe "block" do
        let!(:user) { create(:user, :confirmed, organization: organization, nickname: "some_nickname") }

        context "when having a user" do
          it "flashes a notice message" do
            put :create, params: { user_id: user.id, justification: ::Faker::Lorem.sentence(word_count: 12) }

            expect(flash[:notice]).to be_present
            expect(user.reload.blocked?).to be(true)
          end
        end

        context "when form is invalid" do
          it "flashes an alert message" do
            put :create, params: { user_id: user.id, justification: nil }

            expect(flash[:alert]).to be_present
            expect(user.reload.blocked?).to be(false)
          end
        end

        context "when current user is not an admin" do
          before do
            current_user.admin = false
            current_user.save!
          end

          it "the user remains unblocked" do
            put :create, params: { user_id: user.id, justification: ::Faker::Lorem.sentence(word_count: 12) }

            expect(user.reload.blocked?).to be(false)
          end
        end
      end
    end
  end
end
