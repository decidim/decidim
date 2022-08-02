# frozen_string_literal: true

require "spec_helper"

module Decidim::Votings
  describe OrganizationPromotedVotings do
    subject { described_class.new(organization) }

    let!(:organization) { create(:organization) }
    let!(:local_promoted_voting) do
      create(:voting,
             :promoted,
             organization:)
    end

    let!(:local_promoted_unpublished_voting) do
      create(:voting,
             :unpublished,
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

    let!(:external_promoted_voting) do
      create(:voting, :promoted)
    end

    before { create(:voting) }

    describe "query" do
      it "includes the organization's promoted votings" do
        expect(subject).to include(*local_promoted_voting)
      end

      it "excludes the organization's non promoted votings" do
        expect(subject).not_to include(*local_non_promoted_voting)
      end

      it "excludes the other organization's promoted votings" do
        expect(subject).not_to include(*external_promoted_voting)
      end

      it "excludes other organization's non promoted votings" do
        expect(subject).not_to include(*external_non_promoted_voting)
      end

      it "excludes the organization's promoted non published votings" do
        expect(subject).not_to include(*local_promoted_unpublished_voting)
      end
    end
  end
end
