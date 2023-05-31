# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatoryProcesses
  describe Admin::DestroyParticipatoryProcessType, class: true do
    subject { described_class.new(process_type, user) }

    let(:organization) { create(:organization) }
    let(:process_type) { create(:participatory_process_type, organization:) }
    let(:user) { create(:user, :admin, :confirmed) }

    context "when everything is ok" do
      it "destroys the process type" do
        subject.call
        expect { process_type.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with("delete", process_type, user)
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end
    end
  end
end
