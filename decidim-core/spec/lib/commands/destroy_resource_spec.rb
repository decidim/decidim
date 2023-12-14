# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Commands::DestroyResource do
    subject { described_class.new(resource, user) }

    let(:resource) { create(:dummy_resource) }
    let(:organization) { resource.component.organization }
    let(:user) { create(:user, organization:) }

    context "when everything is ok" do
      it "destroys the resource" do
        subject.call
        expect { resource.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with(:delete, resource, user)
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end
    end
  end
end
