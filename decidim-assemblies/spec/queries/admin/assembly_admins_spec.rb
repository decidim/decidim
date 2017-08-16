# frozen_string_literal: true

require "spec_helper"

describe Decidim::Assemblies::Admin::AdminUsers do
  let(:organization) { create :organization }
  let(:assembly) { create :assembly, organization: organization }
  let!(:admin) { create(:user, :admin, :confirmed, organization: organization) }
  let!(:assembly_admin) do
    create(:user, :admin, :confirmed, organization: organization)
  end

  subject { described_class.new(assembly) }

  it "returns the organization admins and assembly admins" do
    expect(subject.query).to match_array([admin, assembly_admin])
  end
end
