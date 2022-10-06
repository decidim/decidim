# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe OrganizationPrioritizedConferences do
    subject { described_class.new(organization) }

    let!(:organization) { create(:organization) }
    let!(:local_promoted_conference) do
      create(:conference,
             :promoted,
             organization:)
    end

    let!(:local_non_promoted_conference) do
      create(:conference,
             :published,
             organization:)
    end

    before { create(:conference) }

    describe "query" do
      it "orders by promoted status first" do
        expect(subject.to_a).to eq [
          local_promoted_conference,
          local_non_promoted_conference
        ]
      end
    end
  end
end
