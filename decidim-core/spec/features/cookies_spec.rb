# frozen_string_literal: true

require "spec_helper"

describe "Cookies", type: :feature do
  let(:organization) { create(:organization) }
  let(:last_user) { Decidim::User.last }

  before do
    switch_to_host(organization.host)
    visit decidim.root_path
  end

  it "user see the cookie policy" do
    expect(page).to have_content "This site uses cookies."
  end

  it "user accept the cookie policy and he doesn't see it anymore'" do
    click_button "I agree"
    expect(page).to have_no_content "This site uses cookies."

    visit decidim.root_path
    expect(page).to have_no_content "This site uses cookies."
  end
end
