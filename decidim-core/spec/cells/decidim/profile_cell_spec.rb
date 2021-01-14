# frozen_string_literal: true

require "spec_helper"

describe Decidim::ProfileCell, type: :cell do
  controller Decidim::ProfilesController
  subject { my_cell.call }

  let(:organization) { create :organization, user_groups_enabled: true }
  let(:user) { create :user, :managed, organization: organization, blocked: false }
  let(:context) { { content_cell: "decidim/user_conversations", conversations: [] } }
  let(:my_cell) { cell("decidim/profile", user, context: context) }

  context "when show is rendered" do
    it "does not show the inaccessible profile alert" do
      expect(subject).to have_text(user.name)
    end
  end

  context "when the user displayed is blocked" do
    context "and is an admin" do
      let(:user) { create :user, :managed, organization: organization, blocked: true, admin: true }

      it "shows the user profile" do
        expect(subject).not_to have_text("This profile is inaccessible due to Terms and Conditions violation!")
      end
    end

    context "and is not an admin" do
      let(:user) { create :user, :managed, organization: organization, blocked: true, admin: false }

      it "shows the inaccessible profile alert" do
        expect(subject).to have_text("This profile is inaccessible due to Terms and Conditions violation!")
      end
    end
  end
end
