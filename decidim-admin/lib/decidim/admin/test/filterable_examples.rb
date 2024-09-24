# frozen_string_literal: true

shared_context "with filterable context" do
  let(:factory_name) { model_name.singular_route_key }

  def filterable_method(method_name)
    resource_controller.new.send(method_name)
  end

  def apply_filter(options, filter)
    within(".filters__section") do
      find_link("Filter").hover
      find_link(options).hover
      within ".submenu > .is-active > .submenu" do
        click_on(filter)
      end
    end
  end

  def apply_sub_filter(option1, option2, filter)
    within(".filters__section") do
      find_link("Filter").hover
      find_link(option1).hover
      within ".submenu > .is-active > .submenu" do
        find_link(option2).hover
        within ".submenu > .is-active > .submenu" do
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

    after { search_by_text("") }
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
