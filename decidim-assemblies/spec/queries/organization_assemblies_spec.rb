# frozen_string_literal: true

require "spec_helper"

describe Decidim::Assemblies::OrganizationAssemblies do
  subject { described_class.new(organization) }

  let!(:organization) { create(:organization) }
  let!(:local_assemblies) do
    create_list(:assembly, 3, organization: organization)
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
  end
end
