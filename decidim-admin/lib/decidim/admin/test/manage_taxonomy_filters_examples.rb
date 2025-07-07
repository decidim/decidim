# frozen_string_literal: true

shared_examples "manage taxonomy filters in settings" do
  let(:participatory_space_manifests) { [participatory_space.manifest.name] }
  let!(:root_taxonomy) { create(:taxonomy, organization:, name: { en: "A root taxonomy" }) }
  let!(:another_taxonomy) { create(:taxonomy, organization:, parent: root_taxonomy) }
  let(:filters_path) { decidim_admin.taxonomies_path }

  before do
    within "#admin-sidebar-menu-settings" do
      click_on "Components"
    end
  end

  context "when taxonomy filter exist" do
    let!(:another_taxonomy_filter) do
      create(:taxonomy_filter, internal_name: { en: "Another filter" }, participatory_space_manifests: [participatory_space.manifest.name], root_taxonomy:)
    end

    before do
      within "tr", text: translated_attribute(component.name) do
        find("button[data-component='dropdown']").click
        click_on "Configure"
      end
    end

    it "can be added to settings" do
      click_on "Add filter"
      within "#taxonomy_filters-dialog-content" do
        select "A root taxonomy", from: "taxonomy_id"
        select "Internal taxonomy filter name", from: "taxonomy_filter_id"
        within "#save-taxonomy-filter-form" do
          expect(page).to have_content("Public taxonomy filter name")
          expect(page).to have_content(decidim_sanitize_translated(taxonomy.name))
        end
        click_on "Save"
      end

      expect(page).to have_no_css("#taxonomy_filters-dialog-content")
      within ".js-current-filters" do
        expect(page).to have_css("td", text: "Internal taxonomy filter name")
        expect(page).to have_css("td", text: "Public taxonomy filter name")
        expect(page).to have_link("Edit")
      end
      expect(component.reload.settings.taxonomy_filters).to eq([taxonomy_filter.id.to_s])

      click_on "Add filter"
      within "#taxonomy_filters-dialog-content" do
        select "A root taxonomy", from: "taxonomy_id"
        select "Another filter", from: "taxonomy_filter_id"
        click_on "Save"
      end

      expect(page).to have_no_css("#taxonomy_filters-dialog-content")
      within ".js-current-filters" do
        expect(page).to have_css("td", text: "Internal taxonomy filter name")
        expect(page).to have_css("td", text: "Public taxonomy filter name")
        expect(page).to have_css("td", text: "Another filter")
        expect(page).to have_link("Edit", count: 2)
      end
      expect(component.reload.settings.taxonomy_filters).to contain_exactly(taxonomy_filter.id.to_s, another_taxonomy_filter.id.to_s)

      click_on "Update"
      within "tr", text: translated(component.name) do
        find("button[data-component='dropdown']").click
        click_on "Configure"
      end
      within ".js-current-filters" do
        expect(page).to have_css("td", text: "Internal taxonomy filter name")
        expect(page).to have_css("td", text: "Public taxonomy filter name")
      end
    end
  end

  context "when taxonomy filter does not exist" do
    let(:taxonomy_filter_item) { nil }
    let(:taxonomy_filter) { nil }
    before do
      within "tr", text: translated(component.name) do
        find("button[data-component='dropdown']").click
        click_on "Configure"
      end
    end

    it "shows a configuration message" do
      expect(page).to have_content("No taxonomy filters found.")
      expect(page).to have_link("Please define some filters for this participatory space before using this setting", href: filters_path)
    end
  end

  context "when a taxonomy filter is already in settings" do
    let!(:another_taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:, name: { en: "Another taxonomy filter name" }) }

    before do
      component.update!(settings: { taxonomy_filters: [another_taxonomy_filter.id.to_s, taxonomy_filter.id.to_s] })
      within "tr", text: translated(component.name) do
        find("button[data-component='dropdown']").click
        click_on "Configure"
      end
    end

    it "can be removed from settings" do
      within ".js-current-filters" do
        within "tr", text: "Internal taxonomy filter name" do
          find("button[data-component='dropdown']").click
          click_on "Edit"
        end
      end

      within "#taxonomy_filters-dialog-content" do
        click_on "Remove"
      end
      sleep 1
      expect(component.reload.settings.taxonomy_filters).to eq([another_taxonomy_filter.id.to_s])
      expect(page).to have_css("td", text: "Another taxonomy filter name")
      expect(page).to have_no_css("#taxonomy_filters-dialog-content")
      expect(page).to have_no_content("Internal taxonomy filter name")

      click_on "Add filter"
      within "#taxonomy_filters-dialog-content" do
        select "A root taxonomy", from: "taxonomy_id"
        select "Internal taxonomy filter name", from: "taxonomy_filter_id"
        click_on "Save"
      end

      within ".js-current-filters" do
        expect(page).to have_css("td", text: "Another taxonomy filter name")
        expect(page).to have_css("td", text: "Internal taxonomy filter name")
        expect(page).to have_css("td", text: "Public taxonomy filter name")
        within "table" do
          expect(page).to have_css("button[data-component='dropdown']", count: 2)
        end
      end

      click_on "Update"
      within "tr", text: translated(component.name) do
        find("button[data-component='dropdown']").click
        click_on "Configure"
      end
      within ".js-current-filters" do
        expect(page).to have_css("td", text: "Internal taxonomy filter name")
        expect(page).to have_css("td", text: "Public taxonomy filter name")
      end
    end
  end
end
