# frozen_string_literal: true

require "spec_helper"

describe "Home" do
  let!(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
  end

  it "shows the homepage" do
    visit decidim_design.root_path

    within "main" do
      expect(page).to have_content("Decidim Design Guide")
    end
  end
end
