# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UpdateResourcesTaxonomies do
    describe "call" do
      let!(:resource) { create(:dummy_resource) }
      let(:organization) { resource.organization }
      let!(:taxonomy_one) { create(:taxonomy, :with_parent, organization:) }
      let!(:taxonomy) { create(:taxonomy, :with_parent, organization:) }
      let(:taxonomy_ids) { [taxonomy.id] }
      let(:command) { described_class.new(taxonomy_ids, resources, organization) }
      let(:resources) { Dev::DummyResource.where(id: resource.id) }

      subject { command.call }

      context "with no taxonomy" do
        let(:taxonomy_ids) { [] }

        it { is_expected.to broadcast(:invalid_taxonomies) }
      end

      context "with no resources" do
        let(:resources) { [] }

        it { is_expected.to broadcast(:invalid_resources) }
      end

      context "when the taxonomy is the same as the resource's taxonomy" do
        before do
          resource.update!(taxonomies: [taxonomy])
        end

        it "does not update the resource" do
          expect(resource).not_to receive(:update!)
          expect(subject).to broadcast(:update_resources_taxonomies)
        end
      end

      context "when the taxonomy is different from the resource's taxonomy" do
        before do
          resource.update!(taxonomies: [taxonomy_one])
        end

        it "updates the resource" do
          expect(subject).to broadcast(:update_resources_taxonomies)
          expect(resource.reload.taxonomies.first).to eq(taxonomy)
        end
      end
    end
  end
end
