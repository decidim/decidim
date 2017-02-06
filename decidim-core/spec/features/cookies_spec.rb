# frozen_string_literal: true
require "spec_helper"

describe "Cookies", type: :feature do
  let(:organization) { create(:organization) }
  let(:last_user) { Decidim::User.last }
  let!(:static_page) { create(:static_page, slug: 'terms-and-conditions') }

  before do
    switch_to_host(organization.host)
    visit decidim.root_path
  end

  it "user see the cookie policy" do
    expect(page).to have_selector ".cookie-warning"
  end

  it "user accept the cookie policy and he doesn't see it anymore'" do
    page.find(".cookie-warning input[type='submit']").click
    expect(page).not_to have_selector ".cookie-warning"

    visit decidim.root_path
    expect(page).not_to have_selector ".cookie-warning"
  end
end
