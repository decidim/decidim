# frozen_string_literal: true

require "spec_helper"

describe "redirect routes" do
  let!(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
  end

  it "redirects old url with missing locale" do
    visit "/conferences"
    expect(page).to have_current_path("/en/conferences", ignore_query: true)
  end

  it "redirects old url with locale" do
    visit "/conferences?locale=es"
    expect(page).to have_current_path("/es/conferences", ignore_query: true)
  end

  it "redirects user to the new url" do
    user = create(:user, :confirmed, organization:, locale: "ca")
    login_as user, scope: :user
    visit "/"

    visit "/conferences"
    expect(page).to have_current_path("/ca/conferences", ignore_query: true)
  end

  it "redirects user to the new url when using custom locale" do
    user = create(:user, :confirmed, organization:, locale: "ca")
    login_as user, scope: :user
    visit "/"

    visit "/conferences?locale=es"
    expect(page).to have_current_path("/es/conferences", ignore_query: true)
  end

  it "redirects old url with locale and additional params" do
    visit "/conferences/foo-bar?locale=es"
    expect(page).to have_current_path("/es/conferences/foo-bar", ignore_query: true)
  end
end
