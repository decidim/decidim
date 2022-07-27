# frozen_string_literal: true

require "spec_helper"

describe "Homepage initiatives content blocks", type: :system do
  let(:organization) { create(:organization) }
  let!(:initiative) { create(:initiative, organization:) }
  let!(:closed_initiative) { create(:initiative, :rejected, organization:) }

  before do
    create :content_block, organization: organization, scope_name: :homepage, manifest_name: :highlighted_initiatives
    switch_to_host(organization.host)
  end

  it "includes active initiatives to the homepage" do
    visit decidim.root_path

    within "#highlighted-initiatives" do
      expect(page).to have_i18n_content(initiative.title)
      expect(page).not_to have_i18n_content(closed_initiative.title)
    end
  end
end
