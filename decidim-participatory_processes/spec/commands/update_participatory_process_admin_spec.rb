# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryProcesses
  describe Admin::UpdateParticipatoryProcessAdmin, versioning: true do
    subject { described_class.new(form, role) }

    let(:my_process) { create :participatory_process }
    let(:role) { create :participatory_process_user_role, user: user, participatory_process: my_process, role: :admin }
    let(:new_role) { :moderator }
    let!(:current_user) { create :user, email: "some_email@example.org", organization: my_process.organization }
    let!(:user) { create :user, :confirmed, organization: my_process.organization }
    let(:form) do
      double(
        invalid?: invalid,
        current_user: current_user,
        role: new_role
      )
    end
    let(:invalid) { false }

    context "when the form is not valid" do
      let(:invalid) { true }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when no user role is given" do
      let(:role) { nil }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when everything is ok" do
      let(:log_info) do
        {
          resource: {
            title: role.user.name
          }
        }
      end

      it "updates the user role" do
        subject.call
        role.reload

        expect(role.role).to eq "moderator"
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:update!)
          .with(role, current_user, { role: new_role }, log_info)
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)

        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
        expect(action_log.version.event).to eq "update"
      end
    end
  end
end
