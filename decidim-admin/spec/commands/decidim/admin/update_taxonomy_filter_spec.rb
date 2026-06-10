# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UpdateTaxonomyFilter do
    subject { described_class.new(form, taxonomy_filter) }

    let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:) }
    let(:organization) { create(:organization) }
    let(:user) { create(:user, :admin, :confirmed, organization:) }
    let(:form) do
      TaxonomyFilterForm.from_params(
        root_taxonomy_id:,
        taxonomy_items:,
        name:,
        internal_name:,
        participatory_space_manifests:
      ).with_context(
        current_user: user,
        current_organization: organization
      )
    end
    let(:root_taxonomy_id) { root_taxonomy.id }
    let(:root_taxonomy) { create(:taxonomy, organization:) }
    let(:taxonomies) { [create(:taxonomy, parent: root_taxonomy, organization:)] }
    let(:taxonomy_items) { taxonomies.map(&:id) }
    let(:name) { { "en" => "Name" } }
    let(:internal_name) { { "en" => "Internal name" } }
    let(:participatory_space_manifests) { ["participatory_processes"] }

    context "when the form is not valid" do
      before do
        allow(form).to receive(:valid?).and_return(false)
      end

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the form is valid" do
      before do
        subject.call
        taxonomy_filter.reload
      end

      it "updates the filter items" do
        expect(taxonomy_filter.filter_items.map(&:taxonomy_item_id)).to eq(taxonomy_items)
      end

      it "updates the names" do
        expect(taxonomy_filter.name).to eq(name)
        expect(taxonomy_filter.internal_name).to eq(internal_name)
        expect(taxonomy_filter.participatory_space_manifests).to eq(participatory_space_manifests)
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:update!)
          .with(
            taxonomy_filter,
            form.current_user,
            hash_including(:name, :internal_name, :participatory_space_manifests),
            hash_including(extra: hash_including(:filter_items_count, :taxonomy_name))
          )
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
      end
    end

    context "when syncing filter items" do
      let!(:existing_items) { create_list(:taxonomy, 3, parent: root_taxonomy, organization:) }
      let!(:taxonomy_filter) do
        filter = create(:taxonomy_filter, root_taxonomy:)
        existing_items.each { |item| create(:taxonomy_filter_item, taxonomy_filter: filter, taxonomy_item: item) }
        filter
      end
      let(:new_item) { create(:taxonomy, parent: root_taxonomy, organization:) }

      context "with a partial change (one removed, one added)" do
        let(:taxonomies) { [existing_items[0], existing_items[1], new_item] }

        it "removes only deselected items and inserts only newly selected items" do
          subject.call
          expect(taxonomy_filter.reload.filter_items.pluck(:taxonomy_item_id))
            .to contain_exactly(existing_items[0].id, existing_items[1].id, new_item.id)
        end

        it "keeps filter_items_count counter cache accurate" do
          subject.call
          expect(taxonomy_filter.reload.filter_items_count).to eq(3)
        end

        it "keeps per-taxonomy filter_items_count counters accurate" do
          subject.call
          expect(existing_items[0].reload.filter_items_count).to eq(1)
          expect(existing_items[2].reload.filter_items_count).to eq(0)
          expect(new_item.reload.filter_items_count).to eq(1)
        end
      end

      context "when no items changed" do
        let(:taxonomies) { existing_items }

        it "does not recreate existing filter items" do
          original_ids = taxonomy_filter.filter_items.pluck(:id)
          subject.call
          expect(taxonomy_filter.filter_items.reload.pluck(:id)).to match_array(original_ids)
        end
      end

      context "with a large filter" do
        let(:existing_items) { create_list(:taxonomy, 50, parent: root_taxonomy, organization:) }
        let(:taxonomies) { existing_items + [new_item] }

        it "preserves existing filter item rows when adding new ones" do
          original_ids = taxonomy_filter.filter_items.pluck(:id)
          subject.call
          preserved_ids = taxonomy_filter.filter_items.reload.where(taxonomy_item_id: existing_items.map(&:id)).pluck(:id)
          expect(preserved_ids).to match_array(original_ids)
        end
      end
    end
  end
end
