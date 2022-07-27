# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe OrganizationConferences do
    subject { described_class.new(organization) }

    let!(:organization) { create(:organization) }
    let!(:local_conferences) do
      create_list(:conference, 3, organization:)
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
    end
  end
end
