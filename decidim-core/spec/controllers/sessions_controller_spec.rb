# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Devise
    describe SessionsController do
      routes { Decidim::Core::Engine.routes }

      describe "after_sign_in_path_for" do
        subject { controller.after_sign_in_path_for(user) }

        before do
          request.env["decidim.current_organization"] = user.organization
        end

        context "when the given resource is a user" do
          context "and is an admin" do
            let(:user) { build(:user, :admin, sign_in_count: 1) }

            before do
              controller.store_location_for(user, account_path)
            end

            it { is_expected.to eq account_path }
          end

          context "and is not an admin" do
            context "when it is the first time to log in" do
              let(:user) { build(:user, :confirmed, sign_in_count: 1) }

              context "when there are authorization handlers" do
                before do
                  allow(user.organization).to receive(:available_authorizations)
                    .and_return(["dummy_authorization_handler"])
                end

                it { is_expected.to eq("/") }

                context "when there is a pending redirection" do
                  before do
                    controller.store_location_for(user, account_path)
                  end

                  it { is_expected.to eq account_path }
                end

                context "when there is a pending onboarding action with the authorization pending" do
                  let(:permissions) do
                    {
                      "authorization_handlers" => {
                        "dummy_authorization_handler" => { "options" => {} }
                      }
                    }
                  end
                  let(:component) { create(:component, manifest_name: "dummy", organization: user.organization, permissions:) }
                  let(:resource) { create(:dummy_resource, component:) }
                  let(:extended_data) { { "onboarding" => { "model" => resource.to_gid, "action" => "foo" } } }

                  before do
                    user.update(extended_data:)
                  end

                  it { is_expected.to eq("/authorizations/onboarding_pending") }
                end

                context "when the user has not confirmed their email" do
                  before do
                    user.confirmed_at = nil
                  end

                  it { is_expected.to eq("/") }
                end

                context "when the user is blocked" do
                  before do
                    user.blocked = true
                  end

                  it { is_expected.to eq("/") }
                end

                context "when the user is not blocked" do
                  before do
                    user.blocked = false
                  end

                  it { is_expected.to eq("/") }
                end
              end

              context "and otherwise", with_authorization_workflows: [] do
                before do
                  allow(user.organization).to receive(:available_authorizations).and_return([])
                end

                it { is_expected.to eq("/") }
              end
            end

            context "and it is not the first time to log in" do
              let(:user) { build(:user, sign_in_count: 2) }

              it { is_expected.to eq("/") }
            end
          end
        end
      end

      describe "POST create" do
        let(:params) { { user: { email: user.email, password: } } }
        let(:user) { create(:user, :confirmed, password:) }
        let(:password) { "decidim123456789" }

        before do
          request.env["decidim.current_organization"] = user.organization
          request.env["devise.mapping"] = ::Devise.mappings[:user]
        end

        context "when participant" do
          context "with weak password" do
            let(:password) { "decidim123" }

            it "does not update password_updated_at" do
              post(:create, params:)

              expect(user.reload.password_updated_at).not_to be_nil
            end
          end
        end

        context "when admin" do
          context "with strong password" do
            let(:user) { create(:user, :confirmed, :admin) }

            it "does not change password_updated_at" do
              post(:create, params:)

              expect(user.reload.password_updated_at).not_to be_nil
            end
          end

          context "with weak password" do
            let(:user) { create(:user, :confirmed, password:) }
            let(:password) { "decidim123" }

            # To avoid the password validation failing when creating the user
            before do
              user.password = nil
              user.update!(admin: true)
            end

            it "sets password_updated_at to nil" do
              post(:create, params:)

              expect(user.reload.password_updated_at).to be_nil
            end
          end
        end
      end

      describe "DELETE destroy" do
        let(:user) { create(:user, :confirmed) }

        before do
          request.env["decidim.current_organization"] = user.organization
          request.env["devise.mapping"] = ::Devise.mappings[:user]

          sign_in user
        end

        it "clears the current user" do
          delete :destroy

          expect(controller.current_user).to be_nil
        end
      end
    end
  end
end
