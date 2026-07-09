# frozen_string_literal: true

require "spec_helper"

describe "Search filter dropdown" do
  let(:organization) { create(:organization) }
  let(:term) { "dolorem" }

  before do
    driven_by(:iphone)
    switch_to_host(organization.host)
    visit decidim.search_path(term:)
    click_on(id: "dc-dialog-accept")
  end

  it "collapses and expands the filter list through the chevron arrows" do
    trigger = find_by_id("dropdown-trigger-search")
    expect(trigger["aria-expanded"]).to eq("true")

    # the up chevron (last svg) is the visible one while the list is expanded
    trigger.find("svg:last-of-type").click

    expect(page).to have_css("#dropdown-trigger-search[aria-expanded='false']")
    expect(page).to have_no_text("Participatory processes")

    # the down chevron (first svg) is the visible one while the list is collapsed
    trigger.find("svg:first-of-type").click

    expect(page).to have_css("#dropdown-trigger-search[aria-expanded='true']")
    expect(page).to have_text("Participatory processes")
  end
end
