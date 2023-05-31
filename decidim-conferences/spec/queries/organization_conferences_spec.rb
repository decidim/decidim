# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe OrganizationConferences do
    subject { described_class.new(organization) }

    let!(:organization) { create(:organization) }
    let!(:local_conferences) do
      create(:conference, organization:, weight: 2)
      create(:conference, organization:, weight: 3)
      create(:conference, organization:, weight: 1)
    end

    let!(:foreign_conferences) do
      create_list(:conference, 3)
    end

    describe "query" do
      it "includes the organization's conferences" do
        expect(subject).to include(*local_conferences)
      end

      it "excludes the external conferences" do
        expect(subject).not_to include(*foreign_conferences)
      end

      it "order conferences by weight" do
        expect(subject.to_a.first.weight).to eq 1
      end
    end
  end
end
