# frozen_string_literal: true
require "spec_helper"

describe Decidim::Admin::ProcessAdminsRolesForProcess do
  let(:organization) { create :organization }
  let!(:process1) { create :participatory_process, organization: organization }
  let!(:process2) { create :participatory_process, organization: organization }
  let!(:user_role1) { create :participatory_process_user_role, participatory_process: process1 }
  let!(:user_role2) { create :participatory_process_user_role, participatory_process: process2 }

  subject { described_class.new(process1) }

  it "returns only the user roles for the given process" do
    expect(subject.process_admins_roles)
      .to eq [user_role1]
  end
end
