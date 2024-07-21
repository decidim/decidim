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
      click_on "New item"
      fill_in_i18n(
        :taxonomy_element_name,
        "#taxonomy-element_name-tabs",
        en: "New Taxonomy Element"
      )
      click_on "Create item"
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
      click_on "New item"
      fill_in_i18n(
        :taxonomy_element_name,
        "#taxonomy-element_name-tabs",
        en: ""
      )
      click_on "Create item"
    end

    it "displays an error message" do
      expect(page).to have_content("cannot be blank")
    end
  end

  context "when creating a new taxonomy element for a parent taxonomy" do
    let!(:taxonomy) { root_taxonomy }
    let!(:root_taxonomy) { create(:taxonomy, organization:) }
    let!(:parent_taxonomy) { create(:taxonomy, organization:, parent: root_taxonomy) }

    before do
      visit decidim_admin.taxonomies_path
      click_edit_taxonomy
      click_on "New item"
      fill_in_i18n(
        :taxonomy_element_name,
        "#taxonomy-element_name-tabs",
        en: "New Child Element"
      )
      select translated(parent_taxonomy.name), from: "taxonomy_parent_id"
      click_on "Create item"
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

    it "reorders the taxonomies", :js do
      expect(page).to have_css(".js-sortable")

      within ".js-sortable" do
        expect(page).to have_content("Tax 1")
        expect(page).to have_content("Tax 2")
        expect(page).to have_content("Tax 3")
      end

      page.execute_script(<<~JS)
        var first = document.querySelector('.js-sortable tr:first-child');
        var last = document.querySelector('.js-sortable tr:last-child');
        last.parentNode.insertBefore(first, last.nextSibling);
        var event = new Event('sortupdate', {bubbles: true});
        document.querySelector('.js-sortable').dispatchEvent(event);
      JS

      expect(page).to have_css(".js-sortable tr", text: "Tax 2", wait: 5)

      within ".js-sortable" do
        taxonomies = all("tr").map { |row| row.text.match(/Tax \d+/)[0] }
        expect(taxonomies).to eq(["Tax 2", "Tax 3", "Tax 1"])
      end

      # Refresh the page to ensure the order is persisted
      visit current_path

      within ".js-sortable" do
        taxonomies = all("tr").map { |row| row.text.match(/Tax \d+/)[0] }
        expect(taxonomies).to eq(["Tax 2", "Tax 3", "Tax 1"])
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
