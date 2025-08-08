# frozen_string_literal: true

shared_examples_for "a participatory space search with taxonomies" do |factory_name|
  let(:factory_params) do
    space_params
  rescue StandardError
    {}
  end

  let(:filter_params) do
    { with_any_taxonomies: { "#{root_taxonomy.id}": taxonomy_ids } }
  end

  let(:root_taxonomy) { create(:taxonomy, organization:) }
  let(:taxonomy1) { create(:taxonomy, parent: root_taxonomy, organization:) }
  let(:taxonomy2) { create(:taxonomy, parent: root_taxonomy, organization:) }
  let(:child_taxonomy) { create(:taxonomy, organization:, parent: taxonomy2) }
  let!(:space) { create(factory_name, { organization: }.merge(factory_params)) }
  let!(:space2) { create(factory_name, { organization:, taxonomies: [taxonomy1] }.merge(factory_params)) }
  let!(:space3) { create(factory_name, { organization:, taxonomies: [taxonomy2] }.merge(factory_params)) }
  let!(:space4) { create(factory_name, { organization:, taxonomies: [child_taxonomy] }.merge(factory_params)) }

  before do
    get(
      request_path,
      params: { filter: filter_params },
      headers: { "HOST" => organization.host }
    )
  end

  context "when no taxonomy filter is present" do
    let(:filter_params) do
      { with_any_taxonomies: [] }
    end

    it "includes all spaces" do
      expect(subject).to have_escaped_html(translated(space.try(:title) || space.try(:name)))
      expect(subject).to have_escaped_html(translated(space2.try(:title) || space2.try(:name)))
      expect(subject).to have_escaped_html(translated(space3.try(:title) || space3.try(:name)))
      expect(subject).to have_escaped_html(translated(space4.try(:title) || space4.try(:name)))
    end
  end

  context "when no ids are specified" do
    let(:taxonomy_ids) { [] }

    it "includes all spaces" do
      expect(subject).to have_escaped_html(translated(space.try(:title) || space.try(:name)))
      expect(subject).to have_escaped_html(translated(space2.try(:title) || space2.try(:name)))
      expect(subject).to have_escaped_html(translated(space3.try(:title) || space3.try(:name)))
      expect(subject).to have_escaped_html(translated(space4.try(:title) || space4.try(:name)))
    end
  end

  context "when `all` is being sent" do
    let(:taxonomy_ids) { ["all"] }

    it "includes all spaces with the root taxonomy" do
      expect(subject).not_to have_escaped_html(translated(space.try(:title) || space.try(:name)))
      expect(subject).to have_escaped_html(translated(space2.try(:title) || space2.try(:name)))
      expect(subject).to have_escaped_html(translated(space3.try(:title) || space3.try(:name)))
      expect(subject).to have_escaped_html(translated(space4.try(:title) || space4.try(:name)))
    end
  end

  context "when a taxonomy is selected" do
    let(:taxonomy_ids) { [taxonomy2.id] }

    it "includes only spaces for that taxonomy and its children" do
      expect(subject).not_to have_escaped_html(translated(space.try(:title) || space.try(:name)))
      expect(subject).not_to have_escaped_html(translated(space2.try(:title) || space2.try(:name)))
      expect(subject).to have_escaped_html(translated(space3.try(:title) || space3.try(:name)))
      expect(subject).to have_escaped_html(translated(space4.try(:title) || space4.try(:name)))
    end
  end

  context "when multiple taxonomies are selected" do
    let(:taxonomy_ids) { [taxonomy1.id, taxonomy2.id] }

    it "includes only spaces for those taxonomies" do
      expect(subject).not_to have_escaped_html(translated(space.try(:title) || space.try(:name)))
      expect(subject).to have_escaped_html(translated(space2.try(:title) || space2.try(:name)))
      expect(subject).to have_escaped_html(translated(space3.try(:title) || space3.try(:name)))
      expect(subject).to have_escaped_html(translated(space4.try(:title) || space4.try(:name)))
    end
  end

  context "when a sub_taxonomy is selected" do
    let(:taxonomy_ids) { [child_taxonomy.id] }

    it "includes only spaces for that taxonomy" do
      expect(subject).not_to have_escaped_html(translated(space.try(:title) || space.try(:name)))
      expect(subject).not_to have_escaped_html(translated(space2.try(:title) || space2.try(:name)))
      expect(subject).not_to have_escaped_html(translated(space3.try(:title) || space3.try(:name)))
      expect(subject).to have_escaped_html(translated(space4.try(:title) || space4.try(:name)))
    end
  end
end
