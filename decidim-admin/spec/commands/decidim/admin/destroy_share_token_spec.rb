# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe DestroyShareToken do
    subject { described_class.new(share_token, user) }

    let(:organization) { create(:organization) }
    let(:user) { create(:user, :admin, :confirmed, organization:) }
    let(:share_token) { create(:share_token, organization:, user:) }
    let(:extra) do
      {
        participatory_space: {
          title: share_token.participatory_space.title
        },
        resource: {
          title: share_token.component.name
        }
      }
    end

    it "destroys the share_token" do
      subject.call
      expect { share_token.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "broadcasts ok" do
      expect do
        subject.call
      end.to broadcast(:ok)
    end

    it "traces the action", versioning: true do
      expect(Decidim.traceability)
        .to receive(:perform_action!)
        .with(:delete, share_token, user, extra)
        .and_call_original

      expect { subject.call }.to change(Decidim::ActionLog, :count)
      action_log = Decidim::ActionLog.last
      expect(action_log.version).to be_present
    end
  end
end
