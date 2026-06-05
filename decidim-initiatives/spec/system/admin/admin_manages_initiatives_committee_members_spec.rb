# frozen_string_literal: true

require "spec_helper"

describe "User manages the initiatives committee members page" do
  include_context "when admins initiative"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_initiatives.initiatives_path
    click_on translated(initiative.title)
  end

  context "when the initiative does not have promoting committee" do
    let(:initiative_type) { create(:initiatives_type, :promoting_committee_disabled, organization:) }

    it "does not have the committee members section" do
      expect(page).to have_no_text("Committee members")
    end
  end

  context "when the initiative has promoting committee" do
    let(:initiative_type) { create(:initiatives_type, :promoting_committee_enabled, organization:) }

    before do
      click_on "Committee members"
    end

    it "has the committee members section" do
      expect(page).to have_text("Committee members")
    end
  end
end
