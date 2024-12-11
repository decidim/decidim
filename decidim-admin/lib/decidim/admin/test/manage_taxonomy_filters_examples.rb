# frozen_string_literal: true

shared_examples "manage taxonomy filters in settings" do
  let(:space_manifest) { participatory_space.manifest.name }
  let!(:root_taxonomy) { create(:taxonomy, organization:, name: { en: "A root taxonomy" }) }
  let!(:taxonomy_item) { create(:taxonomy, organization:, parent: root_taxonomy) }
  let(:filters_path) { decidim_admin_participatory_processes.participatory_process_filters_path }

  before do
    within "#admin-sidebar-menu-settings" do
      click_on "Components"
    end
  end

  context "when taxonomy filter exist" do
    before do
      click_on "Configure"
    end

    it "can be added to settings" do
      click_on "Add filter"
      within "#taxonomy_filters-dialog-content" do
        select "Internal taxonomy filter name", from: "available-taxonomy_filters"
        expect(page).to have_css("span.label", text: "Internal taxonomy filter name")
        click_on "Save"
      end

      expect(page).to have_no_css("#taxonomy_filters-dialog-content")
      expect(page).to have_css("span.label", text: "Internal taxonomy filter name")
      click_on "Update"
      expect(page).to have_content("The component was updated successfully.")
      expect(component.reload.settings.taxonomy_filters).to eq([taxonomy_filter.id.to_s])
    end
  end

  context "when taxonomy filter does not exist" do
    let(:taxonomy_filter_item) { nil }
    let(:taxonomy_filter) { nil }
    before do
      click_on "Configure"
    end

    it "can be added to settings" do
      expect(page).to have_content("No taxonomy filters found.")
      expect(page).to have_link("Please define some filters for this participatory space before using this setting", href: filters_path)
    end
  end

  context "when a taxonomy filter is already in settings" do
    before do
      component.update!(settings: { taxonomy_filters: [taxonomy_filter.id.to_s] })
      click_on "Configure"
    end

    it "can be removed from settings" do
      expect(page).to have_link("Clear all")
      within "#taxonomy_filters-filters_container" do
        expect(page).to have_css("span.label", text: "Internal taxonomy filter name (1)")
        click_on "Remove"
      end
      expect(page).to have_no_content("Internal taxonomy filter name (1)")
      expect(page).to have_no_link("Clear all")

      click_on "Add filter"
      within "#taxonomy_filters-dialog-content" do
        select "Internal taxonomy filter name (1)", from: "available-taxonomy_filters"
        expect(page).to have_css("span.label", text: "Internal taxonomy filter name (1)")
        click_on "Save"
      end

      within "#taxonomy_filters-filters_container" do
        expect(page).to have_css("span.label", text: "Internal taxonomy filter name (1)")
      end
      click_on "Clear all"

      click_on "Update"
      expect(page).to have_content("The component was updated successfully.")
      expect(component.reload.settings.taxonomy_filters).to eq([])
    end
  end
end
