# frozen_string_literal: true

shared_examples_for "a taxonomizable resource" do
  let(:root_taxonomy) { create(:taxonomy, organization:) }
  let(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:) }
  let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:, participatory_space_manifests: [participatory_space.manifest.name]) }
  let(:taxonomy_filters) { [taxonomy_filter.id] }

  before do
    current_component.update!(settings: { taxonomy_filters: })
  end

  context "when the taxonomies exists" do
    let(:taxonomies) { [taxonomy.id] }

    it { is_expected.to be_valid }
    it { expect(form.taxonomizations.first).to be_kind_of(Decidim::Taxonomization) }
  end

  context "when the taxonomy filter does not exist" do
    let(:taxonomy_filters) { [3456] }

    it { expect(form.taxonomizations).to be_empty }
  end

  context "when the taxonomies are from another organization" do
    let(:taxonomy) { create(:taxonomy) }

    it { expect(form.taxonomizations).to be_empty }
  end

  context "when the taxonomy is a root taxonomy" do
    let(:taxonomy) { create(:taxonomy, organization:) }

    it { expect(form.taxonomizations).to be_empty }
  end
end
