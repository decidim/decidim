# frozen_string_literal: true

require "spec_helper"

describe "Admin manages taxonomies" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:attributes) { attributes_for(:taxonomy) }

  before do
    switch_to_host(organization.host)
    login_as(user, scope: :user)
    visit decidim_admin.taxonomies_path
  end

  it "displays the taxonomies" do
    expect(page).to have_content("Taxonomies")
  end

  context "when creating a new taxonomy" do
    before do
      click_on "New taxonomy"
      fill_in_i18n(
        :taxonomy_name,
        "#taxonomy-name-tabs",
        en: "New Taxonomy"
      )
      click_on "Create taxonomy"
    end

    it "displays a success message" do
      expect(page).to have_content("Taxonomy created successfully.")
    end

    it "creates a new taxonomy" do
      expect(page).to have_content("New Taxonomy")
    end
  end

  context "when creating a new taxonomy with invalid data" do
    before do
      click_on "New taxonomy"
      fill_in_i18n(
        :taxonomy_name,
        "#taxonomy-name-tabs",
        en: ""
      )
      click_on "Create taxonomy"
    end

    it "displays an error message" do
      expect(page).to have_content("cannot be blank")
    end
  end

  context "when creating a new taxonomy element" do
    let!(:taxonomy) { create(:taxonomy, organization:) }

    before do
      visit decidim_admin.taxonomies_path
      click_edit_taxonomy
      click_on "New element"
      fill_in_i18n(
        :taxonomy_element_name,
        "#taxonomy-element_name-tabs",
        en: "New Taxonomy Element"
      )
      select translated(taxonomy.name), from: "taxonomy_parent_id"
      click_on "Create element"
    end

    it "creates a new taxonomy element" do
      expect(page).to have_content("New Taxonomy Element")
    end
  end

  context "when creating a new taxonomy element with invalid data" do
    let!(:taxonomy) { create(:taxonomy, organization:) }

    before do
      visit decidim_admin.taxonomies_path
      click_edit_taxonomy
      click_on "New element"
      fill_in_i18n(
        :taxonomy_element_name,
        "#taxonomy-element_name-tabs",
        en: ""
      )
      select translated(taxonomy.name), from: "taxonomy_parent_id"
      click_on "Create element"
    end

    it "displays an error message" do
      expect(page).to have_content("cannot be blank")
    end
  end

  context "when creating a new taxonomy element for a parent taxonomy" do
    let!(:taxonomy) { root_taxonomy}
    let!(:root_taxonomy) { create(:taxonomy, organization:) }
    let!(:parent_taxonomy) { create(:taxonomy, organization:, parent: root_taxonomy) }

    before do
      visit decidim_admin.taxonomies_path
      click_edit_taxonomy
      click_on "New element"
      fill_in_i18n(
        :taxonomy_element_name,
        "#taxonomy-element_name-tabs",
        en: "New Child Element"
      )
      select translated(parent_taxonomy.name), from: "taxonomy_parent_id"
      click_on "Create element"
    end

    it "creates a new taxonomy element" do
      within(".js-sortable tr", text: translated(parent_taxonomy.name)) do
        expect(page).to have_content("New Child Element")
      end
    end
  end

  context "when editing a taxonomy" do
    let!(:taxonomy) { create(:taxonomy, organization:) }

    before do
      visit decidim_admin.taxonomies_path
      click_edit_taxonomy
      fill_in_i18n(
        :taxonomy_name,
        "#taxonomy-name-tabs",
        en: "Edited Taxonomy"
      )
      click_on "Update"
    end

    it "displays a success message" do
      expect(page).to have_content("Taxonomy updated successfully.")
    end

    it "updates the taxonomy" do
      expect(page).to have_content("Edited Taxonomy")
    end
  end

  context "when deleting a taxonomy" do
    let!(:taxonomy) { create(:taxonomy, organization:) }

    before do
      visit decidim_admin.taxonomies_path
      click_delete_taxonomy
    end

    it "displays a success message" do
      expect(page).to have_content("Taxonomy successfully destroyed.")
    end

    it "deletes the taxonomy" do
      expect(page).to have_no_content(taxonomy.name)
    end
  end

  context "when reordering root taxonomies" do
    let!(:taxonomy1) { create(:taxonomy, :with_children, children_count: 1, name: { en: "Tax 1" }, organization:) }
    let!(:taxonomy2) { create(:taxonomy, :with_children, children_count: 2, name: { en: "Tax 2" }, organization:) }
    let!(:taxonomy3) { create(:taxonomy, :with_children, children_count: 3, name: { en: "Tax 3" }, organization:) }

    before do
      visit decidim_admin.taxonomies_path
    end

    it "reorders the taxonomies" do
      within first(".js-sortable tr") do
        expect(page).to have_content(translated(taxonomy1.name))
      end
      within all(".js-sortable tr")[1] do
        expect(page).to have_content(translated(taxonomy2.name))
      end
      within all(".js-sortable tr").last do
        expect(page).to have_content(translated(taxonomy3.name))
      end

      first(".js-sortable tr").drag_to(all(".js-sortable tr").last)
      sleep 2
      within first(".js-sortable tr") do
        expect(page).to have_content(translated(taxonomy2.name))
      end
      within all(".js-sortable tr")[1] do
        expect(page).to have_content(translated(taxonomy3.name))
      end
      within all(".js-sortable tr").last do
        expect(page).to have_content(translated(taxonomy1.name))
      end
    end
  end

  context "when multiple pages" do
    let!(:taxonomies) { create_list(:taxonomy, 31, organization:) }

    before do
      visit decidim_admin.taxonomies_path(page: 2)
    end

    it "displays the pagination" do
      expect(page).to have_content(translated(taxonomies[15].name))
      expect(page).to have_content("Drag over for previous page")
      expect(page).to have_link("Prev")

      all(".js-sortable tr").last.drag_to(all(".js-sortable tr").first)

      expect(page).to have_content("Drag over for next page")
      expect(page).to have_content(translated(taxonomies[15].name))
      expect(page).to have_no_content(translated(taxonomies[14].name))
    end
  end

  def click_delete_taxonomy
    within "tr", text: translated(taxonomy.name) do
      accept_confirm { click_on "Delete" }
    end
  end

  def click_edit_taxonomy
    within "tr", text: translated(taxonomy.name) do
      click_on "Edit"
    end
  end
end
