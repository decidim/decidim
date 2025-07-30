# frozen_string_literal: true

require "spec_helper"

describe "Admin manages taxonomy filters" do
  include_context "with taxonomy filters context"
  let(:component) { create(:dummy_component, organization:) }
  let!(:taxonomy_filter_sibling) { create(:taxonomy_filter, :with_items, root_taxonomy:, participatory_space_manifests: []) }
  let(:attributes) { attributes_for(:taxonomy_filter) }

  before do
    component.update!(settings: { taxonomy_filters: [taxonomy_filter.id.to_s] })
    switch_to_host(organization.host)
    login_as(user, scope: :user)
    visit decidim_admin.taxonomy_filters_path(taxonomy_id: root_taxonomy.id)
  end

  it "lists the taxonomy filters" do
    expect(page).to have_content("Taxonomy filters")
    within ".table-list" do
      expect(page).to have_content(translated(taxonomy_filter.name))
      expect(page).to have_content(translated(taxonomy_filter_sibling.name), count: 2)
      expect(page).to have_no_content(translated(another_taxonomy_filter.name))
    end
    within "tr", text: translated(taxonomy_filter.name) do
      expect(page).to have_content("The name for regular users")
      expect(page).to have_content("The name for admins only")
      expect(page).to have_content("1")
    end
    within "tr", text: translated(taxonomy_filter_sibling.name) do
      expect(page).to have_content("0")
    end
  end

  context "when creating a new taxonomy filter" do
    let(:last_filter) { Decidim::TaxonomyFilter.last }

    before do
      click_on "New filter"
    end

    it "creates the taxonomy filter" do
      expect(page).to have_content("New taxonomy filter")
      expect(page).to have_field("From taxonomy", with: translated(root_taxonomy.name), disabled: true)
      expect(page).to have_content("7 items selected")
      expect(page).to have_css("#selectAll")
      uncheck "All"
      expect(page).to have_content("0 items selected")
      check "All"
      expect(page).to have_content("7 items selected")
      uncheck translated(taxonomy_with_child.name)
      expect(page).to have_content("5 items selected")

      fill_in_i18n :taxonomy_filter_internal_name, "#taxonomy_filter-internal_name-tabs", en: "A new filter"
      fill_in_i18n :taxonomy_filter_name, "#taxonomy_filter-name-tabs", en: "Category"
      check "All participatory processes"
      click_on "Create taxonomy filter"
      expect(page).to have_content("Taxonomy filter created successfully")
      within "tr", text: translated("A new filter") do
        expect(page).to have_content("0")
        expect(page).to have_content("Category")
      end
      expect(last_filter.filter_items.count).to eq(5)
      expect(last_filter.participatory_space_manifests).to contain_exactly("participatory_processes")
    end
  end

  context "when editing and empty taxonomy" do
    before do
      visit decidim_admin.taxonomy_filters_path(taxonomy_id: another_root_taxonomy.id)
      within "tr", text: translated(another_taxonomy_filter.name) do
        find("button[data-component='dropdown']").click
        click_on "Edit"
      end
    end

    it "shows no elements found" do
      expect(page).to have_content("Edit taxonomy filter")
      expect(page).to have_no_css("#selectAll")
      expect(page).to have_content("No items are available for this taxonomy")
    end
  end

  context "when editing a taxonomy with items" do
    before do
      within "tr", text: translated(taxonomy_filter.name) do
        find("button[data-component='dropdown']").click
        click_on "Edit"
      end
    end

    it "edits the form" do
      expect(page).to have_content("Edit taxonomy filter")
      expect(page).to have_content(translated(taxonomy.name))
      expect(page).to have_content(translated(another_taxonomy.name))
      uncheck translated(taxonomy.name)
      check translated(taxonomy_child.name)
      fill_in_i18n :taxonomy_filter_internal_name, "#taxonomy_filter-internal_name-tabs", en: "A new filter"
      fill_in_i18n :taxonomy_filter_name, "#taxonomy_filter-name-tabs", en: "", ca: "", es: ""
      uncheck "All participatory processes"
      check "All conferences"
      click_on "Update taxonomy filter"
      expect(page).to have_content("Taxonomy filter updated successfully")
      within "tr", text: translated("A new filter") do
        expect(page).to have_content("1")
        expect(page).to have_content(translated(taxonomy_filter.root_taxonomy.name), count: 1)
      end
      expect(taxonomy_filter.filter_items.count).to eq(2)
      expect(taxonomy_filter.filter_items.pluck(:taxonomy_item_id)).to contain_exactly(another_taxonomy.id, taxonomy_child.id)
      expect(taxonomy_filter.reload.participatory_space_manifests).to contain_exactly("assemblies", "conferences")
    end
  end

  context "when destroying a taxonomy filter" do
    before do
      within "tr", text: translated(taxonomy_filter.name) do
        find("button[data-component='dropdown']").click
        accept_confirm { click_on "Delete" }
      end
    end

    it "destroys the taxonomy filter" do
      expect(page).to have_content("Taxonomy filter successfully destroyed")
      expect(page).to have_no_content(translated(taxonomy_filter.name))
      expect(page).to have_content(translated(taxonomy_filter_sibling.name))
    end
  end
end
