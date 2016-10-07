# frozen_string_literal: true
require "spec_helper"

describe "Homepage", type: :feature do
  context "when there's an organization" do
    let(:organization) { create(:organization) }

    before do
      switch_to_host(organization.host)
      visit decidim.root_path
    end

    it "welcomes the user" do
      expect(page).to have_content(organization.name)
    end
  end
end
