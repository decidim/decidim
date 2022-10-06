# frozen_string_literal: true

require "spec_helper"

module Decidim::Accountability
  describe Admin::DestroyResult do
    subject { described_class.new(result, user) }

    let(:result) { create :result }
    let(:organization) { result.component.organization }
    let(:user) { create :user, organization: }

    context "when everything is ok" do
      it "destroys the result" do
        subject.call
        expect { result.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with(:delete, result, user)
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end
    end
  end
end
