# frozen_string_literal: true
require "spec_helper"

describe Decidim::Admin::ManageableParticipatoryProcessesForUser do
  let!(:organization_process) { create :participatory_process, organization: user.organization }
  let!(:external_process) { create :participatory_process }

  subject { described_class.new(user) }

  context "when the user is an admin" do
    let(:user) { create :user, :admin }

    it "returns only the organization processes" do
      expect(subject.query).to eq [organization_process]
    end
  end

  context "when the user is not an admin" do
    let(:user) { create :user }
    let!(:organization_process2) { create :participatory_process, organization: user.organization }

    before do
      create :participatory_process_user_role, user: user, participatory_process: organization_process
    end

    it "returns the processes the user can admin" do
      expect(subject.query).to eq [organization_process]
    end
  end
end
