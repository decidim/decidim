# frozen_string_literal: true

require "spec_helper"

describe "Homepage conferences content blocks" do
  let(:organization) { create(:organization) }
  let(:show_statistics) { true }
  let!(:promoted_conference) { create(:conference, :promoted, organization:) }
  let!(:unpromoted_conference) { create(:conference, organization:) }
  let!(:promoted_external_conference) { create(:conference, :promoted) }
  let!(:highlighted_conferences_content_block) { create(:content_block, organization:, scope_name: :homepage, manifest_name: :highlighted_conferences) }

  include_context "when admin administrating a conference"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  it "includes active conferences to the homepage" do
    visit decidim.root_path

    within "#highlighted-conferences" do
      expect(page).to have_i18n_content(promoted_conference.title)
      expect(page).to have_i18n_content(unpromoted_conference.title)
      expect(page).not_to have_i18n_content(promoted_external_conference.title)

      expect(page).to have_css("a.card__grid", count: 3)
    end
  end

  it "updates the number of highlighted conferences with a number input field" do
    visit decidim_admin.edit_organization_homepage_content_block_path(highlighted_conferences_content_block)

    expect(find("input[type='number'][name='content_block[settings][max_results]']").value).to eq("6")

    fill_in "content_block[settings][max_results]", with: "1"
    click_on "Update"

    expect(page).to have_content("Highlighted conferences")
    expect(highlighted_conferences_content_block.reload.settings["max_results"]).to eq(1)

    visit decidim.root_path

    within "#highlighted-conferences" do
      expect(page).to have_css("a.card__grid", count: 1)
    end
  end
end
