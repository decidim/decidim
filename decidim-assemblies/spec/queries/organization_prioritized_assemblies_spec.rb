# frozen_string_literal: true

require "spec_helper"

module Decidim::Assemblies
  describe OrganizationPrioritizedAssemblies do
    subject { described_class.new(organization) }

    let!(:organization) { create(:organization) }
    let!(:local_promoted_assembly) do
      create(:assembly,
             :promoted,
             organization:)
    end

    let!(:local_non_promoted_assembly) do
      create(:assembly,
             :published,
             organization:)
    end

    before { create(:assembly) }

    describe "query" do
      it "orders by promoted status first" do
        expect(subject.to_a).to eq [
          local_promoted_assembly,
          local_non_promoted_assembly
        ]
      end
    end
  end
end
