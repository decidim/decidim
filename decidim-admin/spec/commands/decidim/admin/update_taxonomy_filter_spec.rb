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
            hash_including(:name, :internal_name, :filter_items, :participatory_space_manifests),
            hash_including(extra: hash_including(:filter_items_count, :taxonomy_name))
          )
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
      end
    end
  end
end
