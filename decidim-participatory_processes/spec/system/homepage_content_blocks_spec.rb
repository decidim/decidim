# frozen_string_literal: true

require "spec_helper"

describe "Homepage processes content blocks" do
  let(:organization) { create(:organization) }
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
  let!(:highlighted_participatory_processes_content_block) { create(:content_block, organization:, scope_name: :homepage, manifest_name: :highlighted_processes) }
  let!(:user) { create(:user, :admin, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  it "includes active processes to the homepage" do
    visit decidim.root_path

    within "#highlighted-processes" do
      expect(page).to have_i18n_content(promoted_process.title)
      expect(page).to have_i18n_content(unpromoted_process.title)
      expect(page).not_to have_i18n_content(promoted_external_process.title)
      expect(page).not_to have_i18n_content(promoted_past_process.title)

      expect(page).to have_css("a.card__grid", count: 2)
    end
  end

  context "when there are promoted process groups" do
    let!(:normal_group) { create(:participatory_process_group, organization:) }
    let!(:promoted_group) { create(:participatory_process_group, :promoted, organization:) }
    let(:promoted_items_titles) { page.all("#highlighted-processes .card__grid .card__grid-text .h4").map(&:text) }

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

  it "updates the number of highlighted participatory processes with a number input field" do
    visit decidim_admin.edit_organization_homepage_content_block_path(highlighted_participatory_processes_content_block)

    expect(find("input[type='number'][name='content_block[settings][max_results]']").value).to eq("6")

    fill_in "content_block[settings][max_results]", with: "1"
    click_on "Update"

    expect(page).to have_content("Highlighted processes")
    expect(highlighted_participatory_processes_content_block.reload.settings["max_results"]).to eq(1)

    visit decidim.root_path

    within "#highlighted-processes" do
      expect(page).to have_css("a.card__grid", count: 1)
    end
  end
end
