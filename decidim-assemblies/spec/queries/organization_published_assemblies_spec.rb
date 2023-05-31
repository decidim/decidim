# frozen_string_literal: true

require "spec_helper"

module Decidim::Assemblies
  describe OrganizationPublishedAssemblies do
    subject { described_class.new(organization) }

    let!(:organization) { create(:organization) }

    let!(:published_assemblies) do
      create(:assembly, :published, organization:, weight: 2)
      create(:assembly, :published, organization:, weight: 3)
      create(:assembly, :published, organization:, weight: 1)
    end

    let!(:unpublished_assemblies) do
      create_list(:assembly, 3, :unpublished, organization:)
    end

    let!(:foreign_assemblies) do
      create_list(:assembly, 3, :published)
    end

    describe "query" do
      it "includes the organization's published assemblies" do
        expect(subject).to include(*published_assemblies)
      end

      it "excludes the organization's unpublished assemblies" do
        expect(subject).not_to include(*unpublished_assemblies)
      end

      it "excludes other organization's published assemblies" do
        expect(subject).not_to include(*foreign_assemblies)
      end

      it "order published assemblies by weight" do
        expect(subject.to_a.first.weight).to eq 1
      end
    end
  end
end
