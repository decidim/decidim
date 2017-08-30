# frozen_string_literal: true

require "spec_helper"

describe "Follow meetings", type: :feature do
  include_context "feature"
  let(:manifest_name) { "meetings" }

  let!(:meeting) do
    create(:meeting, feature: feature)
  end

  before do
    login_as user, scope: :user
  end

  context "when not following the meeting" do
    context "when user clicks the Follow button" do
      it "makes the user follow the meeting" do
        visit resource_locator(meeting).path
        expect do
          click_button "Follow"
          expect(page).to have_content "Stop following"
        end.to change(Decidim::Follow, :count).by(1)
      end
    end
  end

  context "when the user is following the meeting" do
    before do
      create(:follow, followable: meeting, user: user)
    end

    context "when user clicks the Follow button" do
      it "makes the user follow the meeting" do
        visit resource_locator(meeting).path
        expect do
          click_button "Stop following"
          expect(page).to have_content "Follow"
        end.to change(Decidim::Follow, :count).by(-1)
      end
    end
  end
end
