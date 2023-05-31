# frozen_string_literal: true

require "spec_helper"

module Decidim::Votings
  describe OrganizationPublishedVotings do
    subject { described_class.new(organization) }

    let!(:organization) { create(:organization) }

    let!(:published_votings) do
      create_list(:voting, 3, :published, organization:)
    end

    let!(:unpublished_votings) do
      create_list(:voting, 3, :unpublished, organization:)
    end

    let!(:foreign_votings) do
      create_list(:voting, 3, :published)
    end

    describe "query" do
      it "includes the organization's published votings" do
        expect(subject).to include(*published_votings)
      end

      it "excludes the organization's unpublished votings" do
        expect(subject).not_to include(*unpublished_votings)
      end

      it "excludes other organization's published votings" do
        expect(subject).not_to include(*foreign_votings)
      end
    end
  end
end
