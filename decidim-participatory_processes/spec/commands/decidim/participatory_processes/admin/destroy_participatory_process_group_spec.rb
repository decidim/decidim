# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryProcesses
  describe Admin::DestroyParticipatoryProcessGroup do
    let(:organization) { create :organization }
    let(:user) { create :user, :admin, :confirmed, organization: }
    let(:participatory_process_group) { create :participatory_process_group, organization: }
    let(:command) { described_class.new(participatory_process_group, user) }

    it "destroys the participatory process group" do
      command.call
      expect { participatory_process_group.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "broadcasts ok" do
      expect do
        command.call
      end.to broadcast(:ok)
    end

    it "traces the action", versioning: true do
      expect(Decidim.traceability)
        .to receive(:perform_action!)
        .with(
          "delete",
          participatory_process_group,
          user
        )
        .and_call_original

      expect { command.call }.to change(Decidim::ActionLog, :count)

      action_log = Decidim::ActionLog.last
      expect(action_log.version).to be_present
      expect(action_log.version.event).to eq "destroy"
    end
  end
end
