# frozen_string_literal: true

shared_context "with taxonomy filters context" do
  let(:organization) { create(:organization) }
  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let!(:root_taxonomy) { create(:taxonomy, organization:) }
  let!(:another_root_taxonomy) { create(:taxonomy, organization:) }
  let!(:taxonomy) { create(:taxonomy, skip_injection: true, organization:, parent: root_taxonomy) }
  let!(:another_taxonomy) { create(:taxonomy, organization:, parent: root_taxonomy) }
  let!(:taxonomy_with_child) { create(:taxonomy, organization:, parent: root_taxonomy) }
  let!(:taxonomy_child) { create(:taxonomy, organization:, parent: taxonomy_with_child) }
  let!(:taxonomy_filter) { create(:taxonomy_filter, name:, internal_name:, root_taxonomy:, participatory_space_manifests:) }
  let(:name) { { "en" => "The name for regular users" } }
  let(:internal_name) { { "en" => "The name for admins only" } }
  let!(:another_taxonomy_filter) { create(:taxonomy_filter, root_taxonomy: another_root_taxonomy, participatory_space_manifests:) }
  let!(:taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: taxonomy) }
  let!(:another_taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: another_taxonomy) }
  let(:participatory_space_manifests) { %w(participatory_processes assemblies) }
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
