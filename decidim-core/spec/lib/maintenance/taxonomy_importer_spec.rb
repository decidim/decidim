# frozen_string_literal: true

require "spec_helper"
require "decidim/maintenance"

module Decidim::Maintenance
  describe TaxonomyImporter do
    subject { described_class.new(organization, model, roots) }
    let(:organization) { create(:organization) }
    let(:model) { Decidim::ParticipatoryProcess }
    let(:dummy_resource) { create(:dummy_resource, component:) }
    let(:component) { create(:dummy_component, participatory_space:) }
    let(:participatory_space) { create(:participatory_process, organization:) }
    let(:json_taxonomies) do
      {
        "New taxonomy" => {
          "name" => { organization.default_locale => "root_taxonomy" },
          "resources" => {},
          "children" => {
            "New child taxonomy" => {
              "children" => {},
              "resources" => {
                dummy_resource.to_global_id.to_s => "Descriptive title"
              }
            }
          }
        }
      }
    end
    let(:json_filters) do
      {
        "New root taxonomy" => {
          "space_filter" => true,
          "space_manifest" => "participatory_processes",
          "items" => [["New taxonomy", "New child taxonomy"]],
          "components" => [
            component.to_global_id.to_s
          ]
        }
      }
    end
    let(:roots) do
      {
        "New root taxonomy" => {
          "taxonomies" => json_taxonomies,
          "filters" => json_filters
        }
      }
    end

    describe "#import!" do
      let(:root_taxonomy) { Decidim::Taxonomy.roots.first }
      let(:taxonomy) { root_taxonomy.children.first }
      let(:child_taxonomy) { taxonomy.children.first }
      let(:filter) { Decidim::TaxonomyFilter.last }

      it "imports taxonomies and assign them to resources" do
        expect { subject.import! }.to change(Decidim::Taxonomy, :count).by(3)
        expect(dummy_resource.taxonomies.all).to eq([child_taxonomy])
        expect(root_taxonomy.name[organization.default_locale]).to eq("New root taxonomy")
        expect(taxonomy.name[organization.default_locale]).to eq("New taxonomy")
        expect(child_taxonomy.name[organization.default_locale]).to eq("New child taxonomy")
        expect(dummy_resource.taxonomies.all).to eq([child_taxonomy])
      end

      it "imports the filters" do
        expect { subject.import! }.to change(Decidim::TaxonomyFilter, :count).by(1)
        expect(filter.space_filter).to be_truthy
        expect(filter.space_manifest).to eq("participatory_processes")
        expect(filter.filter_items.count).to eq(1)
        expect(filter.filter_items.first.taxonomy_item).to eq(child_taxonomy)
        expect(component.reload.settings["taxonomy_filters"]).to eq([filter.id.to_s])
      end
    end
  end
end
