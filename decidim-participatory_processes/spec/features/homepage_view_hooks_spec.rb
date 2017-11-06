# frozen_string_literal: true

require "spec_helper"

describe "Highlighted Processes", type: :feature do
  let(:organization) { create(:organization) }
  let(:show_statistics) { true }
  let!(:promoted_process) { create(:participatory_process, :promoted, organization: organization) }
  let!(:unpromoted_process) { create(:participatory_process, organization: organization) }
  let!(:promoted_external_process) { create(:participatory_process, :promoted) }

  before do
    switch_to_host(organization.host)
  end

  it "includes active processes to the homepage" do
    visit decidim.root_path

    within "#highlighted-processes" do
      expect(page).to have_i18n_content(promoted_process.title)
      expect(page).to have_i18n_content(unpromoted_process.title)
      expect(page).to_not have_i18n_content(promoted_external_process.title)
    end
  end
end
