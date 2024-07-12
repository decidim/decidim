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
      click_on "Create taxonomy"
      fill_in_i18n(
        :taxonomy_name,
        "#taxonomy-name-tabs",
        en: "New Taxonomy"
      )
      fill_in :taxonomy_weight, with: 1
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
      click_on "Create taxonomy"
      fill_in_i18n(
        :taxonomy_name,
        "#taxonomy-name-tabs",
        en: ""
      )
      fill_in :taxonomy_weight, with: 1
      click_on "Create taxonomy"
    end

    it "displays an error message" do
      expect(page).to have_content("cannot be blank")
    end
  end

  context "when creating a new taxonomy with negative weight" do
    before do
      click_on "Create taxonomy"
      fill_in_i18n(
        :taxonomy_name,
        "#taxonomy-name-tabs",
        en: "New Taxonomy"
      )
      fill_in :taxonomy_weight, with: -1
      click_on "Create taxonomy"
    end

    it "displays an error message" do
      expect(page).to have_content("must be greater than or equal to 0")
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
      fill_in :taxonomy_weight, with: 2
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
    let!(:taxonomy1) { create(:taxonomy, name: { en: "Tax 1" }, organization:, weight: 1) }
    let!(:taxonomy2) { create(:taxonomy, name: { en: "Tax 2" }, organization:, weight: 2) }
    let!(:taxonomy3) { create(:taxonomy, name: { en: "Tax 3" }, organization:, weight: 3) }

    before do
      visit decidim_admin.taxonomies_path
    end

    it "reorders the taxonomies" do
      within first(".js-list-available tr") do
        expect(page).to have_content(translated(taxonomy1.name))
      end
      within all(".js-list-available tr")[1] do
        expect(page).to have_content(translated(taxonomy2.name))
      end
      within all(".js-list-available tr").last do
        expect(page).to have_content(translated(taxonomy3.name))
      end

      first(".js-list-available tr").drag_to(all(".js-list-available tr").last)

      within first(".js-list-available tr") do
        expect(page).to have_content(translated(taxonomy2.name))
      end
      within all(".js-list-available tr")[1] do
        expect(page).to have_content(translated(taxonomy1.name))
      end
      within all(".js-list-available tr").last do
        expect(page).to have_content(translated(taxonomy3.name))
      end
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
