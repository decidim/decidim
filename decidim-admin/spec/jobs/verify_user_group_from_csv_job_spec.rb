# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe VerifyUserGroupFromCsvJob do
      let!(:user_group) { create :user_group, :confirmed, organization: }
      let(:user) { create(:user, :admin, organization:) }
      let(:organization) { create(:organization) }
      let(:email) { user_group.email }

      context "when the user group is confirmed and not verified" do
        it "verifies the user group" do
          expect do
            described_class.perform_now(email, user, organization)
            user_group.reload
          end.to change(user_group, :verified?).from(false).to(true)
        end

        it "delegates the work to a command" do
          expect(Decidim::Admin::VerifyUserGroup).to receive(:call)
          described_class.perform_now(email, user, organization)
        end
      end

      context "when the user group is not confirmed" do
        let!(:user_group) { create :user_group, organization: }

        it "does not verify the user group" do
          expect do
            described_class.perform_now(email, user, organization)
            user_group.reload
          end.not_to change(user_group, :verified?)
        end
      end

      context "when the user group is confirmed and verified" do
        let!(:user_group) { create :user_group, :confirmed, :verified, organization: }

        it "does not verify the user group" do
          expect do
            described_class.perform_now(email, user, organization)
            user_group.reload
          end.not_to change(user_group, :verified?)
        end
      end

      context "when the user group does not belong to the organization" do
        let!(:user_group) { create :user_group, :confirmed }

        it "does not verify the user group" do
          expect do
            described_class.perform_now(email, user, organization)
            user_group.reload
          end.not_to change(user_group, :verified?)
        end
      end

      context "when the email does not exist in the organization groups" do
        let(:email) { "this is not an email" }

        it "does not verify the user group" do
          expect do
            described_class.perform_now(email, user, organization)
            user_group.reload
          end.not_to change(user_group, :verified?)
        end
      end

      context "when the email exists but is wrongly formatted" do
        let(:email) { " #{user_group.email.upcase} " }

        it "verifies the user group" do
          expect do
            described_class.perform_now(email, user, organization)
            user_group.reload
          end.to change(user_group, :verified?).from(false).to(true)
        end
      end
    end
  end
end
