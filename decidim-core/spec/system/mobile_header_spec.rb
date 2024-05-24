# frozen_string_literal: true

require "spec_helper"

describe "Mobile header" do
  let(:organization) { create(:organization) }
  let!(:user) { create(:user, :admin, :confirmed, organization:) }

  before do
    Capybara.current_driver = :iphone
    switch_to_host(organization.host)
    visit decidim.root_path
    click_button "Accept all"
  end

  it "has a login link" do
    expect(page).to have_css(".main-bar__links-mobile__login")
  end

  context "when user login is confirmed" do
    before do
        switch_to_host(organization.host)
        login_as user, scope: :user
        visit decidim.root_path
    end

    it "displays an avatar on the header" do
        expect(page).to have_css(".main-bar__avatar")
    end
  end
end
