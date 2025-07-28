# frozen_string_literal: true

require "spec_helper"

describe "Admin manages assembly publication" do
  include_context "when admin administrating an assembly"

  let(:admin_page_path) { decidim_admin_assemblies.assemblies_path }
  let(:public_collection_path) { decidim_assemblies.assemblies_path }
  let(:title) { "My space" }
  let!(:participatory_space) { assembly }

  it_behaves_like "manage participatory space publications"

  it "displays the entry in last activities" do
    participatory_space.update(title: { en: title })
    participatory_space.unpublish!
    participatory_space.reload

    switch_to_host(organization.host)
    login_as user, scope: :user
    visit admin_page_path

    within("tr", text: translated_attribute(participatory_space.title)) do
      find("button[data-component='dropdown']").click
      click_on "Publish"
    end

    visit decidim.root_path
    visit decidim.last_activities_path

    expect(page).to have_content("New assembly: #{title}")

    within "#filters" do
      find("a", class: "filter", text: "Assembly", match: :first).click
    end
    expect(page).to have_content("New assembly: #{title}")
  end
end
