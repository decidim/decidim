# frozen_string_literal: true

require "spec_helper"

describe Decidim::Commands::DestroyResource do
  subject { described_class.new(resource, user) }

  let(:organization) { create(:organization) }

  context "when destroying a participatory process group" do
    let(:user) { create(:user, :admin, :confirmed, organization:) }
    let(:resource) { create(:participatory_process_group, organization:) }

    it "destroys the participatory process group" do
      subject.call
      expect { resource.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "broadcasts ok" do
      expect do
        subject.call
      end.to broadcast(:ok)
    end

    it "traces the action", versioning: true do
      expect(Decidim.traceability)
        .to receive(:perform_action!)
        .with(:delete, resource, user)
        .and_call_original

      expect { subject.call }.to change(Decidim::ActionLog, :count)

      action_log = Decidim::ActionLog.last
      expect(action_log.version).to be_present
      expect(action_log.version.event).to eq "destroy"
    end
  end
end
