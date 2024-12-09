# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe DestroyTaxonomyFilter do
    subject { described_class.new(taxonomy_filter, user) }

    let(:organization) { create(:organization) }
    let(:user) { create(:user, :admin, :confirmed, organization:) }
    let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:) }
    let(:root_taxonomy) { create(:taxonomy, organization:) }

    it "destroys the taxonomy_filter" do
      subject.call
      expect { taxonomy_filter.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "broadcasts ok" do
      expect do
        subject.call
      end.to broadcast(:ok)
    end

    it "traces the action", versioning: true do
      expect(Decidim.traceability)
        .to receive(:perform_action!)
        .with(
          :delete,
          taxonomy_filter,
          user,
          hash_including(extra: hash_including(:filter_items_count, :taxonomy_name))
        )
        .and_call_original

      expect { subject.call }.to change(Decidim::ActionLog, :count)
    end
  end
end
