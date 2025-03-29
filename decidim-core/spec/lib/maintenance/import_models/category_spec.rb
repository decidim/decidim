# frozen_string_literal: true

require "spec_helper"
require "decidim/maintenance/import_models"
require "decidim/blogs/test/factories"
require_relative "shared_examples"

module Decidim::Maintenance::ImportModels
  describe Category do
    subject { category }

    include_context "with taxonomy importer model context"
    # avoid using factories for this test in case old models are removed
    let!(:category) { described_class.create!(name: { "en" => "Category 1", "ca" => "Categoria 1" }, participatory_space: assembly) }
    let!(:subcategory) { described_class.create!(name: { "en" => "Sub Category 1", "ca" => "Subcategoria 1" }, parent: category, participatory_space: assembly) }
    let!(:sub_subcategory) { described_class.create!(name: { "en" => "Category too deep", "ca" => "Sub Subcategoria 1" }, parent: subcategory, participatory_space: assembly) }
    let!(:another_category) { described_class.create!(name: { "en" => "Another Category 2", "ca" => "Una Altra Categoria 2" }, participatory_space: participatory_process) }

    let!(:categorizable) { Categorization.create!(categorizable: dummy_resource, category:) }
    # a wrongly categorized resource
    let(:another_component) { create(:dummy_component, name: { "en" => "Another Dummy Component" }, participatory_space: participatory_process) }
    let!(:another_resource) { create(:dummy_resource, title: { "en" => "Another Dummy Resource" }, component: another_component, scope: nil) }
    let!(:another_categorizable) { Categorization.create!(categorizable: another_resource, category:) }

    let!(:external_category) { described_class.create!(name: { "en" => "External Category" }, participatory_space: external_participatory_process) }
    let!(:external_categorizable) { Categorization.create!(categorizable: external_resource, category: external_category) }
    let(:root_taxonomy_name) { "~ Categories" }
    let(:common_children) do
      {
        "Sub Category 1" => {
          name: subcategory.name,
          origin: subcategory.to_global_id.to_s,
          children: {},
          resources: subcategory.resources
        },
        "Sub Category 1 > Category too deep" => {
          name: {
            "en" => "Sub Category 1 > Category too deep",
            "ca" => "Sub Subcategoria 1"
          },
          origin: sub_subcategory.to_global_id.to_s,
          children: {},
          resources: sub_subcategory.resources
        }
      }
    end

    before do
      described_class.add_resource_class("Decidim::Dev::DummyResource")
    end

    describe "#name" do
      it "returns the name" do
        expect(subject.name).to eq("en" => "Category 1", "ca" => "Categoria 1")
        expect(subcategory.name).to eq("en" => "Sub Category 1", "ca" => "Subcategoria 1")
      end
    end

    describe "#resources" do
      let(:resource) { dummy_resource }

      it_behaves_like "has resources"
    end

    it_behaves_like "can be converted to taxonomies"
    it_behaves_like "a single root taxonomy"

    describe "#taxonomies" do
      it "returns the taxonomies" do
        expect(subject.taxonomies).to eq(
          name: category.name,
          origin: category.to_global_id.to_s,
          children: common_children,
          resources: subject.resources
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
        expect(hash[:taxonomies].count).to eq(2)
        expect(hash[:taxonomies]["Assembly: Assembly"]).to eq({
                                                                name: { I18n.locale.to_s => "Assembly: Assembly" },
                                                                origin: assembly.to_global_id.to_s,
                                                                children: {
                                                                  "Category 1" => {
                                                                    name: category.name,
                                                                    origin: category.to_global_id.to_s,
                                                                    children: common_children,
                                                                    resources: {
                                                                      dummy_resource.to_global_id.to_s => dummy_resource.title[I18n.locale.to_s]
                                                                    }
                                                                  }
                                                                },
                                                                resources: {}

                                                              })
        expect(hash[:taxonomies]["Participatory process: Participatory Process"]).to eq({
                                                                                          name: { I18n.locale.to_s => "Participatory process: Participatory Process" },
                                                                                          origin: participatory_process.to_global_id.to_s,
                                                                                          children: {
                                                                                            "Another Category 2" => {
                                                                                              name: another_category.name,
                                                                                              origin: another_category.to_global_id.to_s,
                                                                                              children: {},
                                                                                              resources: {}
                                                                                            }
                                                                                          },
                                                                                          resources: {}
                                                                                        })

        expect(hash[:filters].count).to eq(2)
      end

      it "returns the filters for each space" do
        expect(hash[:filters]).to include(
          name: root_taxonomy_name,
          internal_name: "Assembly: Assembly",
          items: [
            ["Assembly: Assembly", "Category 1"],
            ["Assembly: Assembly", "Category 1", "Sub Category 1"],
            ["Assembly: Assembly", "Category 1", "Sub Category 1 > Category too deep"]
          ],
          components: [
            dummy_component.to_global_id.to_s
          ]
        )

        expect(hash[:filters]).to include(
          name: root_taxonomy_name,
          internal_name: "Participatory process: Participatory Process",
          items: [
            ["Participatory process: Participatory Process", "Another Category 2"]
          ],
          components: [
            another_component.to_global_id.to_s
          ]
        )
      end

      context "and a space have no categories" do
        let!(:another_category) { described_class.create!(name: { "en" => "Another Category 2", "ca" => "Una Altra Categoria 2" }, participatory_space: assembly) }

        it "Skips the space" do
          expect(hash[:taxonomies].count).to eq(1)
          expect(hash[:taxonomies]["Assembly: Assembly"]).to eq({
                                                                  name: { I18n.locale.to_s => "Assembly: Assembly" },
                                                                  origin: assembly.to_global_id.to_s,
                                                                  children: {
                                                                    "Category 1" => {
                                                                      name: category.name,
                                                                      origin: category.to_global_id.to_s,
                                                                      children: common_children,
                                                                      resources: {
                                                                        dummy_resource.to_global_id.to_s => dummy_resource.title[I18n.locale.to_s]
                                                                      }
                                                                    },
                                                                    "Another Category 2" => {
                                                                      name: another_category.name,
                                                                      origin: another_category.to_global_id.to_s,
                                                                      children: {},
                                                                      resources: {}
                                                                    }
                                                                  },
                                                                  resources: {}
                                                                })
        end
      end

      context "and a component has no taxonomy filters" do
        let!(:dummy_component) { create(:surveys_component, name: { "en" => "Another Dummy Component" }, participatory_space: assembly) }
        let(:dummy_resource) { nil }
        let(:categorizable) { nil }

        it "Skips the component" do
          expect(hash[:taxonomies].count).to eq(2)

          expect(hash[:filters].count).to eq(1)
          expect(hash[:filters]).to include(
            name: root_taxonomy_name,
            internal_name: "Participatory process: Participatory Process",
            items: [
              ["Participatory process: Participatory Process", "Another Category 2"]
            ],
            components: [
              another_component.to_global_id.to_s
            ]
          )
        end
      end
    end
  end
end
