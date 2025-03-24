# frozen_string_literal: true

require "spec_helper"

describe "Admin manages conference publication" do
  include_context "when admin administrating a conference"

  let(:admin_page_path) { decidim_admin_conferences.edit_conference_path(participatory_space) }
  let(:public_collection_path) { decidim_conferences.conferences_path(locale: I18n.locale) }
  let(:title) { "My space" }
  let!(:participatory_space) { conference }

  it_behaves_like "manage participatory space publications"

  it "displays the entry in last activities" do
    participatory_space.update(title: { en: title })
    participatory_space.unpublish!
    participatory_space.reload

    switch_to_host(organization.host)
    login_as user, scope: :user
    visit admin_page_path
    click_on "Publish"

    visit decidim.last_activities_path
    expect(page).to have_content("New conference: #{title}")

    within "#filters" do
      find("a", class: "filter", text: "Conference", match: :first).click
    end
    expect(page).to have_content("New conference: #{title}")
  end
end
