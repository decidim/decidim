# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Votings
    describe OrganizationVotings do
      subject { described_class.new(organization).query }

      let!(:organization) { create(:organization) }
      let!(:local_votings) do
        create_list(:voting, 3, organization:)
      end

      let!(:foreign_votings) do
        create_list(:voting, 3)
      end

      describe "query" do
        it "includes the organization's votings" do
          expect(subject).to include(*local_votings)
        end

        it "excludes the foreign votings" do
          expect(subject).not_to include(*foreign_votings)
        end
      end
    end
  end
end
