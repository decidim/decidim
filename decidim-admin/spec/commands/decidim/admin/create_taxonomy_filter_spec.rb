# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe CreateTaxonomyFilter do
    subject { described_class.new(form) }

    let(:organization) { create(:organization) }
    let(:user) { create(:user, :admin, :confirmed, organization:) }
    let(:form) do
      TaxonomyFilterForm.from_params(
        root_taxonomy_id:,
        taxonomy_items:,
        name:,
        internal_name:,
        space_filter:
      ).with_context(
        current_user: user,
        current_organization: organization,
        participatory_space_manifest:
      )
    end
    let(:root_taxonomy_id) { root_taxonomy.id }
    let(:root_taxonomy) { create(:taxonomy, organization:) }
    let(:taxonomies) { [create(:taxonomy, parent: root_taxonomy, organization:)] }
    let(:taxonomy_items) { taxonomies.map(&:id) }
    let(:participatory_space_manifest) { :participatory_processes }
    let(:name) { { "en" => "Name" } }
    let(:internal_name) { { "en" => "Internal name" } }
    let(:space_filter) { true }
    let(:last_taxonomy_filter) { Decidim::TaxonomyFilter.last }

    context "when the form is not valid" do
      before do
        allow(form).to receive(:valid?).and_return(false)
      end

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
        expect { subject.call }.not_to change(Decidim::TaxonomyFilter, :count)
      end
    end

    context "when the form is valid" do
      it "creates the taxonomy" do
        expect { subject.call }.to change(Decidim::TaxonomyFilter, :count).by(1)
      end

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "sets the root taxonomy" do
        subject.call
        expect(last_taxonomy_filter.root_taxonomy).to eq(root_taxonomy)
      end

      it "sets the filter items" do
        subject.call
        expect(last_taxonomy_filter.filter_items.map(&:taxonomy_item_id)).to eq(taxonomy_items)
      end

      it "sets the names" do
        subject.call
        expect(last_taxonomy_filter.name).to eq(name)
        expect(last_taxonomy_filter.internal_name).to eq(internal_name)
        expect(last_taxonomy_filter.space_filter).to eq(space_filter)
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:create!)
          .with(
            Decidim::TaxonomyFilter,
            form.current_user,
            hash_including(:root_taxonomy_id, :filter_items, :space_manifest),
            hash_including(extra: hash_including(:space_manifest, :filter_items_count))
          )
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
      end
    end
  end
end
