# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Devise
    describe SessionsController, type: :controller do
      describe "after_sign_in_path_for" do
        subject { controller.after_sign_in_path_for(user) }

        context "when the given resource is a user" do
          context "when it is the first time to log in" do
            let(:user) { build(:user, sign_in_count: 1) }

            context "when there are authorization handlers" do
              before do
                Decidim.authorization_handlers = [Decidim::DummyAuthorizationHandler]
              end

              it { is_expected.to eq("/authorizations") }
            end

            context "otherwise" do
              before do
                Decidim.authorization_handlers = []
              end

              it { is_expected.to eq("/") }
            end
          end

          context "otherwise" do
            let(:user) { build(:user, sign_in_count: 2) }

            it { is_expected.to eq("/") }
          end
        end
      end
    end
  end
end
