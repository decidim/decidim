# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    module Censuses
      describe UserPresenter do
        subject(:presenter) { described_class.new(user) }

        describe "#user" do
          let(:user) { create(:user) }

          it "returns the underlying user object" do
            expect(presenter.user).to eq(user)
          end
        end

        describe "#identifier" do
          context "when user is a Voter with identifier" do
            let(:user) { create(:voter, data: { email: "voter@example.org" }) }

            it "returns the identifier from Voter#identifier" do
              expect(presenter.identifier).to eq("voter@example.org")
            end
          end

          context "when user is a User with name" do
            let(:user) { create(:user, name: "John Doe") }

            it "returns the name from User" do
              expect(presenter.identifier).to eq("John Doe")
            end
          end
        end

        describe "#date_created" do
          context "when user has created_at" do
            let(:created_at) { 10.days.ago }
            let(:user) { create(:user, created_at:) }

            it "returns formatted created_at" do
              expect(presenter.date_created).to eq(I18n.l(created_at, format: :short))
            end
          end
        end
      end
    end
  end
end
