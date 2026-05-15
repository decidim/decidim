# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Commands::RestoreResource do
    subject { described_class.new(resource, user) }

    let(:resource) { create(:dummy_resource) }
    let(:organization) { resource.component.organization }
    let(:user) { create(:user, organization:) }

    before do
      resource.destroy!
    end

    context "when everything is ok" do
      it "restores the resource" do
        subject.call

        expect(resource.reload).not_to be_deleted
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with("restore", resource, user)
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
        expect(action_log.action).to eq("restore")
      end
    end

    context "when the resource is invalid" do
      before do
        allow(subject).to receive(:invalid?).and_return(true)
      end

      it "does not restore the resource and broadcasts :invalid" do
        expect(resource).not_to receive(:restore!)
        expect { subject.call }.to broadcast(:invalid)
      end
    end
  end
end
