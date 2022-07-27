# frozen_string_literal: true

require "spec_helper"

describe "Follow users", type: :system do
  let!(:organization) { create(:organization) }
  let(:user) { create :user, :confirmed, organization: }
  let!(:followable) { create :user, :confirmed, organization: }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when not following the user" do
    context "when user clicks the Follow button" do
      it "makes the user follow the user" do
        visit decidim.profile_path(followable.nickname)
        expect do
          click_button "Follow"
          expect(page).to have_content "Stop following"
        end.to change(Decidim::Follow, :count).by(1)
      end
    end
  end

  context "when the user is following the user" do
    before do
      create(:follow, followable:, user:)
    end

    context "when user clicks the Follow button" do
      it "makes the user follow the user" do
        visit decidim.profile_path(followable.nickname)
        expect do
          click_button "Stop following"
          expect(page).to have_content "Follow"
        end.to change(Decidim::Follow, :count).by(-1)
      end
    end
  end
end
