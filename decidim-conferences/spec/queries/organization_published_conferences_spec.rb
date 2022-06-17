# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe OrganizationPublishedConferences do
    subject { described_class.new(organization) }

    let!(:organization) { create(:organization) }

    let!(:published_conferences) do
      create_list(:conference, 3, :published, organization:)
    end

    let!(:unpublished_conferences) do
      create_list(:conference, 3, :unpublished, organization:)
    end

    let!(:foreign_conferences) do
      create_list(:conference, 3, :published)
    end

    describe "query" do
      it "includes the organization's published conferences" do
        expect(subject).to include(*published_conferences)
      end

      it "excludes the organization's unpublished conferences" do
        expect(subject).not_to include(*unpublished_conferences)
      end

      it "excludes other organization's published conferences" do
        expect(subject).not_to include(*foreign_conferences)
      end
    end
  end
end
