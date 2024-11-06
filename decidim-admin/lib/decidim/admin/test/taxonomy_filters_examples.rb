# frozen_string_literal: true

shared_context "with taxonomy filters context" do
  let(:organization) { create(:organization) }
  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let!(:root_taxonomy) { create(:taxonomy, organization:) }
  let!(:another_root_taxonomy) { create(:taxonomy, organization:) }
  let!(:unselected_root_taxonomy) { create(:taxonomy, organization:) }
  let!(:taxonomy) { create(:taxonomy, skip_injection: true, organization:, parent: root_taxonomy) }
  let!(:another_taxonomy) { create(:taxonomy, organization:, parent: root_taxonomy) }
  let!(:taxonomy_with_child) { create(:taxonomy, organization:, parent: root_taxonomy) }
  let!(:taxonomy_child) { create(:taxonomy, organization:, parent: taxonomy_with_child) }
  let!(:unselected_taxonomy) { create(:taxonomy, organization:, parent: unselected_root_taxonomy) }
  let!(:unselected_taxonomy_child) { create(:taxonomy, organization:, parent: unselected_taxonomy) }
  let!(:another_unselected_taxonomy_child) { create(:taxonomy, organization:, parent: unselected_taxonomy) }
  let!(:unselected_taxonomy_grandchild) { create(:taxonomy, organization:, parent: unselected_taxonomy_child) }
  let!(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:, space_manifest:) }
  let!(:another_taxonomy_filter) { create(:taxonomy_filter, root_taxonomy: another_root_taxonomy, space_manifest:) }
  let!(:taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: taxonomy) }
  let!(:another_taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: another_taxonomy) }
end

shared_examples "having no taxonomy filters defined" do
  let!(:taxonomy_filter) { create(:taxonomy_filter) }
  let!(:taxonomy_filter_item) { nil }
  let!(:another_taxonomy_filter) { create(:taxonomy_filter) }
  let!(:another_taxonomy_filter_item) { nil }

  it "shows no taxonomy filters" do
    expect(page).to have_content("Taxonomies")
    expect(page).to have_content("No taxonomy filters found.")
    expect(page).to have_link("Please define some filters for this participatory space before using this setting")
  end
end

shared_examples "a taxonomy filters controller" do
  it "lists the taxonomy filters" do
    expect(page).to have_content("Taxonomy filters")
    within ".table-list" do
      expect(page).to have_content(translated(taxonomy_filter.name))
      expect(page).to have_content(translated(another_taxonomy_filter.name))
    end
    within "tr", text: translated(taxonomy_filter.name) do
      expect(page).to have_content("2")
    end
    within "tr", text: translated(another_taxonomy_filter.name) do
      expect(page).to have_content("0")
    end
  end

  context "when editing and empty taxonomy" do
    before do
      within "tr", text: translated(another_taxonomy_filter.name) do
        click_on "Edit"
      end
    end

    it "shows no elements found" do
      expect(page).to have_content("Edit taxonomy filter")
      expect(page).to have_content("Taxonomy filter")
      expect(page).to have_content("No items are available for this taxonomy")
    end
  end

  context "when editing a taxonomy with items" do
    before do
      within "tr", text: translated(taxonomy_filter.name) do
        click_on "Edit"
      end
    end

    it "edits the form" do
      expect(page).to have_content("Edit taxonomy filter")
      expect(page).to have_content("Taxonomy filter")
      expect(page).to have_content(translated(taxonomy.name))
      expect(page).to have_content(translated(another_taxonomy.name))
      uncheck translated(taxonomy.name)
      check translated(taxonomy_child.name)
      click_on "Update taxonomy filter"
      expect(page).to have_content("Taxonomy filter updated successfully")
      within "tr", text: translated(taxonomy_filter.name) do
        expect(page).to have_content("3")
      end
      expect(taxonomy_filter.filter_items.count).to eq(3)
      expect(taxonomy_filter.filter_items.pluck(:taxonomy_item_id)).to contain_exactly(another_taxonomy.id, taxonomy_with_child.id, taxonomy_child.id)
    end
  end

  context "when creating a new taxonomy filter" do
    before do
      click_on "New taxonomy filter"
    end

    it "creates the taxonomy filter" do
      expect(page).to have_content("New taxonomy filter")
      select(translated(unselected_root_taxonomy.name), from: "Root taxonomy")
      expect(page).to have_content("4 items available")
      uncheck translated(unselected_taxonomy_child.name)
      uncheck translated(unselected_taxonomy_grandchild.name)
      click_on "Create taxonomy filter"
      expect(page).to have_content("Taxonomy filter created successfully")
      within "tr", text: translated(unselected_root_taxonomy.name) do
        expect(page).to have_content("2")
      end
    end
  end

  context "when destroying a taxonomy filter" do
    before do
      within "tr", text: translated(taxonomy_filter.name) do
        accept_confirm { click_on "Delete" }
      end
    end

    it "destroys the taxonomy filter" do
      expect(page).to have_content("Taxonomy filter successfully destroyed")
      expect(page).to have_no_content(translated(taxonomy_filter.name))
      expect(page).to have_content(translated(another_taxonomy_filter.name))
    end
  end
end
