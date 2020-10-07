# frozen_string_literal: true

require "spec_helper"

describe "Trustee zone", type: :system do
  let(:organization) { user.organization }
  let(:user) { create(:user, :confirmed) }
  let(:trustee) { create(:trustee, user: user, public_key: public_key) }
  let(:public_key) { nil }

  before do
    trustee
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  it "can access to the trustee zone" do
    visit decidim.account_path

    expect(page).to have_content("Trustee zone")

    click_link "Trustee zone"

    expect(page).to have_content("Trustee identification keys")
  end

  it "can generate their identification keys" do
    visit decidim_elections_trustee_zone.root_path

    expect(page).to have_content("Generate keys")
  end

  context "when the trustee has a public key" do
    let(:public_key) { "abcd" }

    it "can upload their identification keys" do
      visit decidim_elections_trustee_zone.root_path

      expect(page).to have_content("Upload your identification keys")
    end
  end

  context "when the user is not a trustee" do
    let(:trustee) { create(:trustee) }

    it "can't access to the trustee zone" do
      visit decidim.account_path

      expect(page).not_to have_content("Trustee zone")

      visit decidim_elections_trustee_zone.root_path

      expect(page).to have_content("You are not authorized to perform this action")

      expect(page).to have_current_path(decidim.root_path)
    end
  end
end
