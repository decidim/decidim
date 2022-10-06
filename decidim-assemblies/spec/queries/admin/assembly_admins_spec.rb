# frozen_string_literal: true

require "spec_helper"

module Decidim::Assemblies::Admin
  describe AdminUsers do
    subject { described_class.new(assembly) }

    let(:organization) { create :organization }
    let!(:assembly) { create :assembly, organization: }
    let!(:admin) { create(:user, :admin, :confirmed, organization:) }
    let!(:assembly_admin_role) { create(:assembly_user_role, assembly:, user: assembly_admin) }
    let(:assembly_admin) { create(:user, organization:) }
    let!(:other_assembly_admin_role) { create(:assembly_user_role, user: other_assembly_admin) }
    let(:other_assembly_admin) { create(:user, organization:) }
    let!(:normal_user) { create(:user, :confirmed, organization:) }
    let!(:other_organization_user) { create(:user, :confirmed) }

    it "returns the organization admins and assembly admins" do
      expect(subject.query).to match_array([admin, assembly_admin])
    end

    context "when asking for organization admin users" do
      subject { described_class.new(nil, organization) }

      it "returns all the organization admins and assembly admins" do
        expect(subject.query).to match_array([admin, assembly_admin, other_assembly_admin])
      end
    end
  end
end
