# frozen_string_literal: true

require "spec_helper"
require "decidim/maintenance"

module Decidim::Maintenance
  describe TaxonomyImporter do
    subject { described_class.new(organization, roots) }
    let(:organization) { create(:organization) }
    let(:dummy_resource) { create(:dummy_resource, component:) }
    let(:component) { create(:dummy_component, participatory_space:) }
    let(:participatory_space) { create(:participatory_process, organization:) }
    let(:resource_id) { dummy_resource.to_global_id.to_s }
    let(:component_id) { component.to_global_id.to_s }
    let(:json_taxonomies) do
      {
        "New taxonomy" => {
          "name" => { organization.default_locale => "New taxonomy", "ca" => "Nova taxonomia" },
          "resources" => {},
          "children" => {
            "New child taxonomy" => {
              "name" => child_name,
              "children" => {},
              "resources" => {
                resource_id => "Descriptive title"
              }
            }
          }
        }
      }
    end
    let(:json_filters) do
      [
        {
          "name" => "New root taxonomy",
          "space_filter" => space_filter,
          "space_manifest" => space_manifest,
          "items" => [["New taxonomy", "New child taxonomy"]],
          "components" => [
            component_id
          ]
        }
      ]
    end
    let(:space_filter) { true }
    let(:space_manifest) { "participatory_processes" }
    let(:child_name) { {} }
    let(:roots) do
      {
        "New root taxonomy" => {
          "taxonomies" => json_taxonomies,
          "filters" => json_filters
        }
      }
    end

    describe "#import!" do
      let(:root_taxonomy) { Decidim::Taxonomy.find_by("name->>? = ?", organization.default_locale, "New root taxonomy") }
      let(:taxonomy) { root_taxonomy.children.find_by("name->>? = ?", organization.default_locale, "New taxonomy") }
      let(:child_taxonomy) { taxonomy.children.find_by("name->>? = ?", organization.default_locale, "New child taxonomy") }
      let(:filter) { Decidim::TaxonomyFilter.last }

      it "imports taxonomies and assign them to resources" do
        expect { subject.import! }.to change(Decidim::Taxonomy, :count).by(3)
        expect(root_taxonomy.name[organization.default_locale]).to eq("New root taxonomy")
        expect(taxonomy.name[organization.default_locale]).to eq("New taxonomy")
        expect(taxonomy.name["ca"]).to eq("Nova taxonomia")
        expect(child_taxonomy.name[organization.default_locale]).to eq("New child taxonomy")
        expect(child_taxonomy.name["ca"]).to be_nil
        expect(dummy_resource.taxonomies.all).to eq([child_taxonomy])
      end

      it "imports the filters" do
        expect { subject.import! }.to change(Decidim::TaxonomyFilter, :count).by(1)
        expect(filter.space_filter).to be_truthy
        expect(filter.space_manifest).to eq("participatory_processes")
        expect(filter.filter_items.count).to eq(1)
        expect(filter.filter_items.first.taxonomy_item).to eq(child_taxonomy)
        expect(component.reload.settings[:taxonomy_filters]).to eq([filter.id.to_s])
      end

      context "when different values are used" do
        let(:space_filter) { false }
        let(:space_manifest) { "assemblies" }
        let(:child_name) { { organization.default_locale => "New child taxonomy", "ca" => "Nova taxonomia filla" } }

        it "imports the filters" do
          expect { subject.import! }.to change(Decidim::TaxonomyFilterItem, :count).by(1)
          expect(child_taxonomy.name[organization.default_locale]).to eq("New child taxonomy")
          expect(child_taxonomy.name["ca"]).to eq("Nova taxonomia filla")
          expect(filter.space_filter).to be_falsey
          expect(filter.space_manifest).to eq("assemblies")
          expect(filter.filter_items.count).to eq(1)
          expect(filter.filter_items.first.taxonomy_item).to eq(child_taxonomy)
          expect(component.reload.settings[:taxonomy_filters]).to eq([filter.id.to_s])
        end
      end

      it "sets the result with the changes performed" do
        subject.import!
        expect(subject.result[:taxonomies_created]).to eq(["New root taxonomy", "New taxonomy", "New child taxonomy"])
        expect(subject.result[:taxonomies_assigned]["New child taxonomy"]).to eq([resource_id])
        expect(subject.result[:filters_created]["participatory_processes: New root taxonomy"]).to eq(["New taxonomy > New child taxonomy"])
        expect(subject.result[:failed_resources]).to be_empty
        expect(subject.result[:failed_components]).to be_empty
      end

      context "when the resource does not exists" do
        let(:resource_id) { "gid://dummy_resource/999" }

        it "does not assign the taxonomy to the resource" do
          expect { subject.import! }.to change(Decidim::Taxonomy, :count).by(3)
          expect(dummy_resource.taxonomies.all).to be_empty
          expect(subject.result[:failed_resources]).to eq([resource_id])
        end
      end

      context "when a component does not exists" do
        let(:component_id) { "gid://dummy_component/999" }

        it "does not assign the filter to the component" do
          expect { subject.import! }.to change(Decidim::Taxonomy, :count).by(3)
          expect(filter.filter_items.count).to eq(1)
          expect(filter.filter_items.first.taxonomy_item).to eq(child_taxonomy)
          expect(component.reload.settings[:taxonomy_filters]).to be_empty
          expect(subject.result[:failed_components]).to eq([component_id])
        end
      end

      context "when the root taxonomy already exists" do
        let!(:root_taxonomy) { create(:taxonomy, organization:, name: { organization.default_locale => "New root taxonomy" }) }

        it "does not create the taxonomy" do
          expect { subject.import! }.to change(Decidim::Taxonomy, :count).by(2)
          expect(taxonomy.parent).to eq(root_taxonomy)
          expect(dummy_resource.taxonomies.all).to eq([child_taxonomy])
        end

        context "when the taxonomy already exists" do
          let!(:taxonomy) { create(:taxonomy, organization:, name: { organization.default_locale => "New taxonomy" }, parent: root_taxonomy) }

          it "does not create the taxonomy" do
            expect { subject.import! }.to change(Decidim::Taxonomy, :count).by(1)
            expect(child_taxonomy.parent).to eq(taxonomy)
            expect(dummy_resource.taxonomies.all).to eq([child_taxonomy])
          end
        end
      end

      context "when a taxonomy already exists with a different parent" do
        let!(:another_taxonomy) { create(:taxonomy, :with_parent, organization:, name: { organization.default_locale => "New taxonomy" }) }

        it "Creates new taxonomies" do
          expect { subject.import! }.to change(Decidim::Taxonomy, :count).by(3)
          expect(taxonomy.parent).to eq(root_taxonomy)
          expect(child_taxonomy.parent).to eq(taxonomy)
          expect(dummy_resource.taxonomies.all).to eq([child_taxonomy])
          expect(Decidim::Taxonomy.count).to eq(5)
        end
      end

      context "when a child taxonomy already exists with a different parent" do
        let(:root_taxonomy) { create(:taxonomy, organization:, name: { organization.default_locale => "New root taxonomy" }) }
        let!(:another_taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:) }
        let!(:another_child_taxonomy) { create(:taxonomy, parent: another_taxonomy, organization:, name: { organization.default_locale => "New child taxonomy" }) }

        it "Creates the necessary taxonomies" do
          expect { subject.import! }.to change(Decidim::Taxonomy, :count).by(2)
          expect(child_taxonomy.parent).to eq(taxonomy)
          expect(dummy_resource.taxonomies.all).to eq([child_taxonomy])
          expect(Decidim::Taxonomy.count).to eq(5)
        end
      end

      context "when a filter already exists" do
        let!(:root_taxonomy) { create(:taxonomy, organization:, name: { organization.default_locale => "New root taxonomy" }) }
        let!(:filter) { create(:taxonomy_filter, root_taxonomy:, space_filter: true, space_manifest: "participatory_processes") }

        it "does not create the filter but creates its items" do
          expect { subject.import! }.not_to change(Decidim::TaxonomyFilter, :count)
          expect(filter.filter_items.count).to eq(1)
          expect(filter.filter_items.first.taxonomy_item).to eq(child_taxonomy)
        end

        context "when the filter items already exists" do
          let(:root_taxonomy) { create(:taxonomy, organization:, name: { organization.default_locale => "New root taxonomy" }) }
          let(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:, name: { organization.default_locale => "New taxonomy" }) }
          let(:child_taxonomy) { create(:taxonomy, parent: taxonomy, organization:, name: { organization.default_locale => "New child taxonomy" }) }
          let!(:filter_item) { create(:taxonomy_filter_item, taxonomy_item: child_taxonomy, taxonomy_filter: filter) }

          it "does not create the items" do
            expect { subject.import! }.not_to change(Decidim::TaxonomyFilterItem, :count)
            expect(filter.filter_items.count).to eq(1)
            expect(filter.filter_items.first.taxonomy_item).to eq(child_taxonomy)
          end
        end
      end
    end
  end
end
