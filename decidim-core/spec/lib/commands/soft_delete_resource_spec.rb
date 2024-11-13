# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Commands::SoftDeleteResource do
    subject { described_class.new(resource, user) }

    let(:resource) { create(:dummy_resource) }
    let(:organization) { resource.component.organization }
    let(:user) { create(:user, organization:) }

    context "when everything is ok" do
      it "soft deletes the resource" do
        subject.call

        expect(resource.reload.trashed?).to be(true)
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with("soft_delete", resource, user)
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
        expect(action_log.action).to eq("soft_delete")
      end

      it "sends a notification to the authors" do
        expect(subject).to receive(:send_notification_to_authors)

        subject.call
      end
    end

    context "when the resource is invalid" do
      before do
        allow(subject).to receive(:invalid?).and_return(true)
      end

      it "does not soft delete the resource and broadcasts :invalid" do
        expect(resource).not_to receive(:trash!)
        expect { subject.call }.to broadcast(:invalid)
      end
    end
  end
end
