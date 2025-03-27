# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe BlockUserController do
      routes { Decidim::Admin::Engine.routes }

      let(:organization) { create(:organization) }
      let(:current_user) { create(:user, :admin, :confirmed, organization:) }

      before do
        request.env["decidim.current_organization"] = organization
        sign_in current_user, scope: :user
      end

      describe "unblock" do
        shared_examples "unblocking a user" do
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

        context "when its a user" do
          let!(:user) { create(:user, :blocked, :confirmed, organization:, nickname: "some_nickname") }

          it_behaves_like "unblocking a user"
        end
      end

      describe "block" do
        shared_examples "blocking a user" do
          context "when having a user" do
            it "flashes a notice message" do
              put :create, params: { user_id: user.id, justification: ::Faker::Lorem.sentence(word_count: 12) }

              expect(flash[:notice]).to be_present
              expect(user.reload.blocked?).to be(true)
              expect(response).not_to redirect_to(moderated_users_path(blocked: true))
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

        context "when its a user" do
          let!(:user) { create(:user, :confirmed, organization:, nickname: "some_nickname") }

          it_behaves_like "blocking a user"
        end
      end
    end
  end
end
