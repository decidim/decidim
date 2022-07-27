# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ParticipatoryProcessesWithUserRole do
    subject { described_class.new(user, :admin) }

    let!(:organization_process) { create :participatory_process, organization: user.organization }
    let!(:external_process) { create :participatory_process }

    context "when the user is an admin" do
      let(:user) { create :user, :admin }

      it "returns only the organization processes" do
        expect(subject.query).to eq [organization_process]
      end
    end

    context "when the user is not an admin" do
      let(:user) { create :user }
      let!(:unmanageable_process) { create :participatory_process, organization: user.organization }

      before do
        create :participatory_process_user_role, user:, participatory_process: organization_process
      end

      it "returns the processes the user can admin" do
        expect(subject.query).to eq [organization_process]
      end
    end
  end
end
