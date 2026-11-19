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

      describe "new" do
        context "when user is found" do
          let!(:user) { create(:user, :confirmed, organization:) }

          it "renders new template" do
            get :new, params: { user_id: user.id }

            expect(subject).to render_template(:new)
          end
        end

        context "when user is not found" do
          it "sets flash alert message and redirects back" do
            get :new, params: { user_id: 999_999_999 }

            expect(flash[:alert]).to be_present
            expect(flash[:alert]).to eq("No user found")
            expect(response).to redirect_to(officializations_path)
          end
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

      describe "bulk_create" do
        let(:justification) { ::Faker::Lorem.sentence(word_count: 12) }
        let(:request_params) { { user_ids: [target_user.id], block_users: { justification: } } }
        let!(:target_user) { create(:user, :admin, :confirmed, organization:) }

        shared_examples "denies bulk blocking" do
          it "does not block the target user" do
            post :bulk_create, params: request_params

            expect(target_user.reload.blocked?).to be(false)
            expect(flash[:alert]).to be_present
          end
        end

        context "when current user is a user manager" do
          let(:current_user) { create(:user, :user_manager, :confirmed, organization:) }

          it_behaves_like "denies bulk blocking"
        end

        context "when current user is a space administrator" do
          let(:participatory_process) { create(:participatory_process, organization:) }
          let(:current_user) { create(:process_admin, :confirmed, organization:, participatory_process:) }

          it_behaves_like "denies bulk blocking"
        end
      end

      describe "bulk_destroy" do
        let!(:blocked_user) do
          create(
            :user,
            :blocked,
            :confirmed,
            organization:,
            nickname: "blocked_nickname",
            extended_data: { "user_name" => "Original name" }
          )
        end

        shared_examples "denies bulk unblocking" do
          it "does not unblock the target user" do
            delete :bulk_destroy, params: { user_ids: [blocked_user.id] }

            expect(blocked_user.reload.blocked?).to be(true)
            expect(flash[:alert]).to be_present
          end
        end

        context "when current user is a user manager" do
          let(:current_user) { create(:user, :user_manager, :confirmed, organization:) }

          it_behaves_like "denies bulk unblocking"
        end

        context "when current user is a space administrator" do
          let(:participatory_process) { create(:participatory_process, organization:) }
          let(:current_user) { create(:process_admin, :confirmed, organization:, participatory_process:) }

          it_behaves_like "denies bulk unblocking"
        end
      end
    end
  end
end
