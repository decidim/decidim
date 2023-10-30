# frozen_string_literal: true

require "spec_helper"

describe "User passwords" do
  let(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
    visit decidim.root_path
  end

  it "can toggle the password field" do
    click_link "Log in", match: :first
    fill_in :session_user_password, with: "hello world"
    expect(find("#session_user_password")["type"]).to eq "password"
    find("button[aria-controls=session_user_password]").click
    expect(find("#session_user_password")["type"]).to eq "text"
  end
end
