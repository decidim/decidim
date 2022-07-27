# frozen_string_literal: true

require "spec_helper"

module Decidim::Assemblies
  describe OrganizationAssemblies do
    subject { described_class.new(organization) }

    let!(:organization) { create(:organization) }
    let!(:local_assemblies) do
      create(:assembly, organization:, weight: 2)
      create(:assembly, organization:, weight: 3)
      create(:assembly, organization:, weight: 1)
    end

    let!(:foreign_assemblies) do
      create_list(:assembly, 3)
    end

    describe "query" do
      it "includes the organization's assemblies" do
        expect(subject).to include(*local_assemblies)
      end

      it "excludes the external assemblies" do
        expect(subject).not_to include(*foreign_assemblies)
      end

      it "order assemblies by weight" do
        expect(subject.to_a.first.weight).to eq 1
      end
    end
  end
end
