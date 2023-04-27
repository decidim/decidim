# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe ParticipatorySpace::DestroyAdmin, versioning: true do
    subject { described_class.new(role, current_user) }

    shared_examples "destroys participatory space role" do
      let!(:current_user) { create :user, email: "some_email@example.org", organization: my_process.organization }
      let!(:user) { create :user, :confirmed, organization: my_process.organization }

      let(:log_info) do
        {
          resource: {
            title: role.user.name
          }
        }
      end

      it "deletes the user role" do
        subject.call
        expect { role.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "traces the action" do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with("delete", role, current_user, log_info)
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)

        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
        expect(action_log.version.event).to eq "destroy"
      end
    end

    context "when the role is a participatory space admin" do
      let(:my_process) { create :participatory_process }
      let(:role) { create :participatory_process_user_role, user:, participatory_process: my_process, role: :admin }

      include_examples "destroys participatory space role"
    end

    context "when the role is a conference admin" do
      let(:my_process) { create :conference }
      let(:role) { create :conference_user_role, user:, conference: my_process, role: :admin }

      include_examples "destroys participatory space role"
    end

    context "when the role is an assembly admin" do
      let(:my_process) { create :assembly }
      let(:role) { create :assembly_user_role, user:, assembly: my_process, role: :admin }

      include_examples "destroys participatory space role"
    end
  end
end
