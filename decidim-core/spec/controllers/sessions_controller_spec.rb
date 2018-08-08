# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Devise
    describe SessionsController, type: :controller do
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
              let(:user) { build(:user, sign_in_count: 1) }

              context "when there are authorization handlers" do
                context "when there is no skip first login authorization option" do
                  before do
                    user.organization.available_authorizations = ["dummy_authorization_handler"]
                    user.organization.save
                  end
                  it { is_expected.to eq("/authorizations/first_login") }
                end

                context "when there is a skip first login authorization option activated" do
                  before do
                    Decidim.config.skip_first_login_authorization = false
                    user.organization.available_authorizations = ["dummy_authorization_handler"]
                    user.organization.save
                  end
                  it { is_expected.to eq("/authorizations/first_login") }
                end

                context "when there is a skip first login authorization option activated" do
                  before do
                    Decidim.config.skip_first_login_authorization = true
                    user.organization.available_authorizations = ["dummy_authorization_handler"]
                    user.organization.save
                  end
                  it { is_expected.to eq("/") }
                end

                context "when there's a pending redirection" do
                  before do
                    controller.store_location_for(user, account_path)
                  end

                  it { is_expected.to eq account_path }
                end
              end

              context "otherwise", with_authorization_workflows: [] do
                it { is_expected.to eq("/") }
              end
            end

            context "and it's not the first time to log in" do
              let(:user) { build(:user, sign_in_count: 2) }

              it { is_expected.to eq("/") }
            end
          end
        end
      end
    end
  end
end
