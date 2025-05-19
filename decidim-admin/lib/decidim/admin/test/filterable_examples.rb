# frozen_string_literal: true

shared_context "with filterable context" do
  let(:factory_name) { model_name.singular_route_key }

  def filterable_method(method_name)
    resource_controller.new.send(method_name)
  end

  def apply_filter(options, filter)
    within(".filters__section") do
      find_link("Filter").click
      find_link(options).click
      within ".dropdown .dropdown__right[aria-hidden='false']" do
        click_on(filter)
      end
    end
  end

  def apply_sub_filter(option1, option2, filter)
    within(".filters__section") do
      find_link("Filter").click
      find_link(option1).click
      within ".dropdown .dropdown__right[aria-hidden='false']" do
        find_link(option2).click
        within ".dropdown .dropdown__right[aria-hidden='false']" do
          click_on(filter)
        end
      end
    end
  end

  def remove_applied_filter(filter)
    within("[data-applied-filters-tags] .label", text: /#{filter}/i) do
      click_on("Cancel")
    end
  end

  def search_by_text(text)
    within(".filters__section") do
      fill_in("q[#{filterable_method(:search_field_predicate)}]", with: text)
      find("*[type=submit]").click
    end
  end

  def page_has_content(text)
    text = [text] unless text.is_a?(Array)
    text.each do |t|
      expect(page).to have_content(t)
    end
  end

  def page_has_no_content(text)
    text = [text] unless text.is_a?(Array)
    text.each do |t|
      expect(page).to have_no_content(t)
    end
  end

  shared_examples "paginating a collection" do
    unless block_given?
      let!(:collection) do
        create_list(factory_name, 50, organization:)
      end
    end

    it_behaves_like "a paginated collection"
  end

  shared_examples "searching by text" do
    it "finds content" do
      txt = text.is_a?(Array) ? text : [text]
      txt.each do |t|
        search_by_text(ActionView::Base.full_sanitizer.sanitize(t))
        page_has_content(ActionView::Base.full_sanitizer.sanitize(t))
      end
    end
  end

  shared_examples "a filtered collection" do |options:, filter:|
    before { apply_filter(options, filter) }

    it { page_has_content(in_filter) }
    it { page_has_no_content(not_in_filter) }

    it_behaves_like "searching by text" do
      let(:text) { in_filter }
    end

    context "when removing applied filter" do
      before { remove_applied_filter(filter) }

      it { page_has_content(in_filter) }
      it { page_has_content(not_in_filter) }

      it_behaves_like "searching by text" do
        let(:text) { not_in_filter }
      end
    end
  end

  shared_examples "a sub-filtered collection" do |option1:, option2:, filter:|
    before { apply_sub_filter(option1, option2, filter) }

    it { page_has_content(in_filter) }
    it { page_has_no_content(not_in_filter) }

    it_behaves_like "searching by text" do
      let(:text) { in_filter }
    end

    context "when removing applied filter" do
      before { remove_applied_filter(filter) }

      it { page_has_content(in_filter) }
      it { page_has_content(not_in_filter) }

      it_behaves_like "searching by text" do
        let(:text) { not_in_filter }
      end
    end
  end
end

shared_examples "filtering collection by published/unpublished" do
  include_context "with filterable context"

  unless block_given?
    let!(:published_space) do
      create(factory_name, published_at: Time.current, organization:)
    end

    let!(:unpublished_space) do
      create(factory_name, published_at: nil, organization:)
    end
  end

  it_behaves_like "a filtered collection", options: "Published", filter: "Published" do
    let(:in_filter) { translated(published_space.title) }
    let(:not_in_filter) { translated(unpublished_space.title) }
  end

  it_behaves_like "a filtered collection", options: "Published", filter: "Unpublished" do
    let(:in_filter) { translated(unpublished_space.title) }
    let(:not_in_filter) { translated(published_space.title) }
  end

  it_behaves_like "paginating a collection"
end

shared_examples "filtering collection by private/public" do
  include_context "with filterable context"

  unless block_given?
    let!(:public_space) do
      create(factory_name, private_space: false, organization:)
    end

    let!(:private_space) do
      create(factory_name, private_space: true, organization:)
    end
  end

  it_behaves_like "a filtered collection", options: "Private", filter: "Public" do
    let(:in_filter) { translated(public_space.title) }
    let(:not_in_filter) { translated(private_space.title) }
  end

  it_behaves_like "a filtered collection", options: "Private", filter: "Private" do
    let(:in_filter) { translated(private_space.title) }
    let(:not_in_filter) { translated(public_space.title) }
  end

  it_behaves_like "paginating a collection"
end

shared_examples "a collection filtered by taxonomies" do
  let(:root_taxonomy1) { create(:taxonomy, organization:, name: { "en" => "Root1" }) }
  let(:root_taxonomy2) { create(:taxonomy, organization:, name: { "en" => "Root2" }) }
  let!(:taxonomy11) { create(:taxonomy, parent: root_taxonomy1, organization:, name: { "en" => "Taxonomy11" }) }
  let!(:taxonomy12) { create(:taxonomy, parent: root_taxonomy1, organization:, name: { "en" => "Taxonomy12" }) }
  let!(:taxonomy21) { create(:taxonomy, parent: root_taxonomy2, organization:, name: { "en" => "Taxonomy21" }) }
  let!(:taxonomy22) { create(:taxonomy, parent: root_taxonomy2, organization:, name: { "en" => "Taxonomy22" }) }
  let(:taxonomy1_filter1) { create(:taxonomy_filter, root_taxonomy: root_taxonomy1, participatory_space_manifests: [participatory_space.manifest.name]) }
  let(:taxonomy2_filter1) { create(:taxonomy_filter, root_taxonomy: root_taxonomy2, participatory_space_manifests: [participatory_space.manifest.name]) }
  let!(:taxonomy_filter_item11) { create(:taxonomy_filter_item, taxonomy_filter: taxonomy1_filter1, taxonomy_item: taxonomy11) }
  let!(:taxonomy_filter_item12) { create(:taxonomy_filter_item, taxonomy_filter: taxonomy1_filter1, taxonomy_item: taxonomy12) }
  let!(:taxonomy_filter_item21) { create(:taxonomy_filter_item, taxonomy_filter: taxonomy2_filter1, taxonomy_item: taxonomy21) }
  let!(:taxonomy_filter_item22) { create(:taxonomy_filter_item, taxonomy_filter: taxonomy2_filter1, taxonomy_item: taxonomy22) }

  before do
    component.update!(settings: { taxonomy_filters: [taxonomy1_filter1.id, taxonomy2_filter1.id] })
    visit current_path
  end

  it_behaves_like "a sub-filtered collection", option1: "Taxonomy", option2: "Root1", filter: "Taxonomy11" do
    let(:in_filter) { resource_with_taxonomy11_title }
    let(:not_in_filter) { [resource_with_taxonomy12_title, resource_with_taxonomy21_title, resource_with_taxonomy22_title] }
  end

  it_behaves_like "a sub-filtered collection", option1: "Taxonomy", option2: "Root2", filter: "Taxonomy21" do
    let(:in_filter) { resource_with_taxonomy21_title }
    let(:not_in_filter) { [resource_with_taxonomy11_title, resource_with_taxonomy12_title, resource_with_taxonomy22_title] }
  end

  it_behaves_like "a filtered collection", options: "Taxonomy", filter: "Root1" do
    let(:in_filter) { [resource_with_taxonomy11_title, resource_with_taxonomy12_title] }
    let(:not_in_filter) { [resource_with_taxonomy21_title, resource_with_taxonomy22_title] }
  end

  it_behaves_like "a filtered collection", options: "Taxonomy", filter: "Root2" do
    let(:in_filter) { [resource_with_taxonomy21_title, resource_with_taxonomy22_title] }
    let(:not_in_filter) { [resource_with_taxonomy11_title, resource_with_taxonomy12_title] }
  end
end
