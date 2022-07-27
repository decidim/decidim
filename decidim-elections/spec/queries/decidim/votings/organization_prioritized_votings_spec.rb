# frozen_string_literal: true

require "spec_helper"

module Decidim::Votings
  describe OrganizationPrioritizedVotings do
    subject { described_class.new(organization) }

    let!(:organization) { create(:organization) }
    let!(:local_promoted_voting) do
      create(:voting,
             :promoted,
             organization:)
    end

    let!(:local_non_promoted_voting) do
      create(:voting,
             :published,
             organization:)
    end

    let!(:external_non_promoted_voting) do
      create(:voting, :published)
    end

    before { create(:voting) }

    describe "query" do
      it "orders by promoted status first" do
        expect(subject.to_a).to eq [
          local_promoted_voting,
          local_non_promoted_voting
        ]
      end
    end
  end
end
