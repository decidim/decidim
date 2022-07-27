# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryProcesses
  describe Admin::AdminUsers do
    subject { described_class.new(participatory_process) }

    let(:organization) { create :organization }
    let!(:participatory_process) { create :participatory_process, organization: }
    let!(:admin) { create(:user, :admin, :confirmed, organization:) }
    let!(:participatory_process_admin_role) { create(:participatory_process_user_role, participatory_process:, user: participatory_process_admin) }
    let(:participatory_process_admin) { create(:user, organization:) }
    let!(:other_participatory_process_admin_role) { create(:participatory_process_user_role, user: other_participatory_process_admin) }
    let(:other_participatory_process_admin) { create(:user, organization:) }
    let!(:normal_user) { create(:user, :confirmed, organization:) }
    let!(:other_organization_user) { create(:user, :confirmed) }

    it "returns the organization admins and participatory process admins" do
      expect(subject.query).to match_array([admin, participatory_process_admin])
    end

    context "when asking for organization admin users" do
      subject { described_class.new(nil, organization) }

      it "returns all the organization admins and participatory process admins" do
        expect(subject.query).to match_array([admin, participatory_process_admin, other_participatory_process_admin])
      end
    end
  end
end
