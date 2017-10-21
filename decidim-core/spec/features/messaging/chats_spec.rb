# frozen_string_literal: true

require "spec_helper"

describe "Chats" do
  let(:organization) { create(:organization) }
  let(:user) { create :user, :confirmed, organization: organization }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim.root_path
  end

  it "links to list of chats from topbar nav" do
    within ".topbar__user__logged" do
      find(".icon--envelope-closed").click
    end

    expect(page).to have_content("You have no chats yet")
  end
end
