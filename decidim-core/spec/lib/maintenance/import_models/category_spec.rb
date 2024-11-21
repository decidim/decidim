# frozen_string_literal: true

require "spec_helper"
require "decidim/maintenance/import_models"

module Decidim::Maintenance::ImportModels
  describe Category do
    subject { category }

    let(:organization) { create(:organization) }
    let(:taxonomy) { create(:taxonomy, :with_parent, organization:) }
    let!(:sub_taxonomy) { create(:taxonomy, parent: taxonomy, organization:) }
    let!(:another_taxonomy) { create(:taxonomy, :with_parent, organization:) }
    let(:taxonomies) { [sub_taxonomy, another_taxonomy] }
    # avoid using factories for this test in case old models are removed
    let!(:category) { described_class.create!(name: { "en" => "Category 1", "ca" => "Categoria 1" }, participatory_space: participatory_process) }
    let!(:subcategory) { described_class.create!(name: { "en" => "Sub Category 1", "ca" => "Subcategoria 1" }, parent: category, participatory_space: participatory_process) }
    let!(:another_category) { described_class.create!(name: { "en" => "Another Category 2", "ca" => "Una Altra Categoria 2" }, participatory_space: assembly) }
    let!(:participatory_process) { create(:participatory_process, taxonomies:, organization:) }
    let!(:assembly) { create(:assembly, organization:) }
    let!(:dummy_component) { create(:dummy_component, name: { "en" => "Dummy Component" }, participatory_space: assembly) }
    let!(:dummy_resource) { create(:dummy_resource, title: { "en" => "Dummy Resource" }, component: dummy_component, scope: nil) }
    let!(:metric) { create(:metric, participatory_space: participatory_process, decidim_category_id: subcategory.id) }
    let!(:categorizable) { Categorization.create!(categorizable: dummy_resource, category:) }
    let(:external_organization) { create(:organization) }
    let(:external_taxonomy) { create(:taxonomy, :with_parent, organization: external_organization) }
    let!(:external_category) { described_class.create!(name: { "en" => "External Category" }, participatory_space: external_process) }
    let!(:external_process) { create(:participatory_process, organization: external_organization) }
    let!(:external_component) { create(:dummy_component, name: { "en" => "External Dummy Component" }, participatory_space: external_process) }
    let!(:external_resource) { create(:dummy_resource, title: { "en" => "External Dummy Resource" }, component: external_component, scope: nil, decidim_category_id: external_category.id) }
    let(:root_taxonomy_name) { "~ Categories" }

    before do
      allow_any_instance_of(Decidim::Metric).to receive(:to_s).and_return("Metric 1") # rubocop:disable RSpec/AnyInstance
    end

    describe "#name" do
      it "returns the name" do
        expect(subject.name).to eq("en" => "Category 1", "ca" => "Categoria 1")
      end
    end

    describe "#resources" do
      it "returns the resources" do
        expect(subject.resources).to eq({ dummy_resource.to_global_id.to_s => dummy_resource.title[I18n.locale.to_s] })
        expect(subcategory.resources).to eq({ metric.to_global_id.to_s => "Metric 1" })
      end
    end

    describe "#taxonomies" do
      it "returns the taxonomies" do
        expect(subject.taxonomies).to eq(
          name: category.name,
          children: {
            subcategory.name[I18n.locale.to_s] => {
              name: subcategory.name,
              children: {},
              resources: subcategory.resources
            }
          },
          resources: subject.resources
        )
      end
    end

    describe ".to_taxonomies" do
      it "returns the categories" do
        expect(described_class.with(organization).to_taxonomies).to eq(
          root_taxonomy_name => described_class.to_h
        )
      end
    end

    describe ".to_h" do
      let(:hash) { described_class.with(organization).to_h }
      let(:all_items) do
        [
          ["Category Type", "Category 1"],
          ["Category 2"]
        ]
      end

      it "returns the scopes as taxonomies for each space" do
        expect(hash[:taxonomies]).to eq(
          another_category.name[I18n.locale.to_s] => another_category.taxonomies
        )
        expect(hash[:filters].count).to eq(3)
      end

      it "returns the filters for each space" do
        %w(assemblies participatory_processes initiatives).each do |space_manifest|
          expect(hash[:filters]).to include(
            {
              space_filter: true,
              space_manifest:,
              name: root_taxonomy_name,
              items: all_items,
              components: []
            }
          )
        end
      end
    end
  end
end
