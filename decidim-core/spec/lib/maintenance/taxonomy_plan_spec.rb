# frozen_string_literal: true

require "spec_helper"
require "decidim/maintenance"

module Decidim::Maintenance
  describe TaxonomyPlan do
    subject { described_class.new(organization, models) }
    let(:dummy_model) { double(:dummy_model, table_name: "dummy_model_table", to_taxonomies: "some taxonomies") }
    let(:organization) { create(:organization) }
    let(:models) { [dummy_model] }
    let!(:taxonomy) { create(:taxonomy, :with_parent, :with_children, organization:) }
    let!(:another_taxonomy) { create(:taxonomy, :with_parent, organization:) }

    before do
      allow(dummy_model).to receive(:with).and_return(dummy_model)
    end

    describe "#existing_taxonomies" do
      it "returns the existing taxonomies" do
        expect(subject.existing_taxonomies).to eq(
          taxonomy.parent.name[organization.default_locale] => {
            taxonomy.name[organization.default_locale] => [
              taxonomy.children.first.name[organization.default_locale],
              taxonomy.children.second.name[organization.default_locale],
              taxonomy.children.third.name[organization.default_locale]
            ]
          },
          another_taxonomy.parent.name[organization.default_locale] => {
            another_taxonomy.name[organization.default_locale] => []
          }
        )
      end
    end

    describe "#imported_taxonomies" do
      it "returns the imported taxonomies" do
        expect(subject.imported_taxonomies).to eq(
          dummy_model.table_name => "some taxonomies"
        )
      end

      context "when a block is given" do
        it "yields the model" do
          expect { |b| subject.imported_taxonomies(&b) }.to yield_with_args(dummy_model)
        end
      end
    end

    describe "#to_h" do
      it "returns the organization and taxonomies" do
        expect(subject.to_h).to eq(
          organization: {
            id: organization.id,
            locale: organization.default_locale,
            host: organization.host,
            name: organization.name[organization.default_locale]
          },
          existing_taxonomies: subject.existing_taxonomies,
          imported_taxonomies: subject.imported_taxonomies
        )
      end

      context "when a block is given" do
        it "yields the model" do
          expect { |b| subject.to_h(&b) }.to yield_with_args(dummy_model)
        end
      end
    end

    describe "#to_json" do
      it "returns the organization and taxonomies as JSON" do
        expect(subject.to_json).to eq(
          JSON.pretty_generate(subject.to_h)
        )
      end

      context "when a block is given" do
        it "yields the model" do
          expect { |b| subject.to_json(&b) }.to yield_with_args(dummy_model)
        end
      end
    end

    describe "#import" do
      let(:data) do
        {
          "imported_taxonomies" => {
            dummy_model.table_name => []
          }
        }
      end

      it "uses the importer to import the taxonomies" do
        expect_any_instance_of(subject.importer).to receive(:import!) # rubocop:disable RSpec/AnyInstance
        subject.import(data)
      end

      context "when a block is given" do
        it "yields the importer" do
          expect { |b| subject.import(data, &b) }.to yield_with_args(subject.importer, dummy_model.table_name)
        end
      end
    end
  end
end
