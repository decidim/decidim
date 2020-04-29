# frozen_string_literal: true

require "spec_helper"

describe "Homepage processes content blocks", type: :system do
  let(:organization) { create(:organization) }
  let(:show_statistics) { true }
  let!(:promoted_process) { create(:participatory_process, :promoted, organization: organization) }
  let!(:promoted_past_process) do
    create(
      :participatory_process,
      :promoted,
      organization: organization,
      start_date: 1.month.ago,
      end_date: 1.week.ago
    )
  end
  let!(:unpromoted_process) { create(:participatory_process, organization: organization) }
  let!(:promoted_external_process) { create(:participatory_process, :promoted) }

  before do
    create :content_block, organization: organization, scope: :homepage, manifest_name: :highlighted_processes
    switch_to_host(organization.host)
  end

  it "includes active processes to the homepage" do
    visit decidim.root_path

    within "#highlighted-processes" do
      expect(page).to have_i18n_content(promoted_process.title)
      expect(page).to have_i18n_content(unpromoted_process.title)
      expect(page).not_to have_i18n_content(promoted_external_process.title)
      expect(page).not_to have_i18n_content(promoted_past_process.title)
    end
  end
end
