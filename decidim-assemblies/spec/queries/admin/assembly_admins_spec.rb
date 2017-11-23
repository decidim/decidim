# frozen_string_literal: true

require "spec_helper"

module Decidim::Assemblies
  describe Admin::AdminUsers do
    subject { described_class.new(assembly) }

    let(:organization) { create :organization }
    let(:assembly) { create :assembly, organization: organization }
    let!(:admin) { create(:user, :admin, :confirmed, organization: organization) }
    let!(:assembly_admin) do
      create(:user, :admin, :confirmed, organization: organization)
    end

    it "returns the organization admins and assembly admins" do
      expect(subject.query).to match_array([admin, assembly_admin])
    end
  end
end
