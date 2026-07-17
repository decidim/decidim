# frozen_string_literal: true

require "spec_helper"

describe "View more toggle" do
  let(:organization) { create(:organization) }
  let(:long_description) { { en: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. " * 10 } }
  let!(:participatory_process) { create(:participatory_process, :active, organization:, description: long_description) }

  before do
    create(:content_block, organization:, scope_name: :participatory_process_homepage, manifest_name: :main_data, scoped_resource_id: participatory_process.id, weight: 1)
    create(:content_block, organization:, scope_name: :participatory_process_homepage, manifest_name: :main_data, scoped_resource_id: participatory_process.id, weight: 2)
    switch_to_host(organization.host)
    visit decidim_participatory_processes.participatory_process_path(participatory_process, locale: I18n.locale)
  end

  it "renders both view more panels collapsed" do
    expect(page).to have_button("More information", count: 2)
    expect(page).to have_css("[id^='panel-view-more'][inert]", count: 2)
  end

  it "expands only the panel whose button is clicked" do
    buttons = all(:button, "More information")
    first_panel = buttons[0]["data-controls"]
    second_panel = buttons[1]["data-controls"]

    buttons[0].click

    expect(buttons[0]).to have_text("Show less")
    expect(buttons[1]).to have_text("More information")
    expect(page).to have_css("##{first_panel}:not([inert])")
    expect(page).to have_css("##{second_panel}[inert]")
  end
end
