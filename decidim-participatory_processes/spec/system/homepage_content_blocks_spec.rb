# frozen_string_literal: true

require "spec_helper"

describe "Homepage processes content blocks", type: :system do
  let(:organization) { create(:organization) }
  let(:show_statistics) { true }
  let!(:promoted_process) { create(:participatory_process, :promoted, organization:) }
  let!(:promoted_past_process) do
    create(
      :participatory_process,
      :promoted,
      organization:,
      start_date: 1.month.ago,
      end_date: 1.week.ago
    )
  end
  let!(:unpromoted_process) { create(:participatory_process, organization:) }
  let!(:promoted_external_process) { create(:participatory_process, :promoted) }

  before do
    create :content_block, organization: organization, scope_name: :homepage, manifest_name: :highlighted_processes
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

  context "when there are promoted process groups" do
    let!(:normal_group) { create(:participatory_process_group, organization:) }
    let!(:promoted_group) { create(:participatory_process_group, :promoted, organization:) }
    let(:promoted_items_titles) { page.all("#highlighted-processes .card__title").map(&:text) }

    it "includes promoted group in first place in the same homepage block" do
      visit decidim.root_path

      within "#highlighted-processes" do
        expect(promoted_items_titles.first).to eq(translated(promoted_group.title, locale: :en))
        expect(promoted_items_titles).to include(translated(promoted_process.title, locale: :en))
        expect(promoted_items_titles).to include(translated(unpromoted_process.title, locale: :en))
        expect(promoted_items_titles).not_to include(translated(promoted_external_process.title, locale: :en))
        expect(promoted_items_titles).not_to include(translated(promoted_past_process.title, locale: :en))
      end
    end
  end
end
