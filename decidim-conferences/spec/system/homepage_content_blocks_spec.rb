# frozen_string_literal: true

require "spec_helper"

describe "Homepage conferences content blocks", type: :system do
  let(:organization) { create(:organization) }
  let(:show_statistics) { true }
  let!(:promoted_conference) { create(:conference, :promoted, organization:) }
  let!(:unpromoted_conference) { create(:conference, organization:) }
  let!(:promoted_external_conference) { create(:conference, :promoted) }

  before do
    create :content_block, organization: organization, scope_name: :homepage, manifest_name: :highlighted_conferences
    switch_to_host(organization.host)
  end

  it "includes active conferences to the homepage" do
    visit decidim.root_path

    within "#highlighted-conferences" do
      expect(page).to have_i18n_content(promoted_conference.title)
      expect(page).to have_i18n_content(unpromoted_conference.title)
      expect(page).not_to have_i18n_content(promoted_external_conference.title)
    end
  end
end
