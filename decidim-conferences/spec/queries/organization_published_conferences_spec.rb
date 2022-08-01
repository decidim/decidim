# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe OrganizationPublishedConferences do
    subject { described_class.new(organization) }

    let!(:organization) { create(:organization) }

    let!(:published_conferences) do
      create(:conference, :published, organization:, start_date: 1.year.ago, end_date: 1.year.ago + 3.days)
      create(:conference, :published, organization:, start_date: 30.days.ago, end_date: 30.days.ago + 7.days)
      create(:conference, :published, organization:, start_date: 7.days.from_now, end_date: 7.days.from_now + 4.days)
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

      it "order conferences by start date" do
        expect(subject.to_a.first.start_date).to eq 7.days.from_now.to_date
      end
    end
  end
end
