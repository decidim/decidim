# frozen_string_literal: true
require "spec_helper"

module Decidim
  describe InviteAdminForm do
    subject do
      described_class.from_params(
        attributes,
        current_process: participatory_process,
        current_organization: organization
      )
    end

    context "when everything is OK" do
      it "is valid"
    end

    it "downcases the email"

    context "when a user exists for the given email" do
      it "is invalid"
    end

    context "when no organization given" do
      it "defaults to the current organization"
    end

    context "when no inviter given" do
      it "defaults to the current user"
    end
  end
end
