# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe DestroyParticipatorySpacePrivateUser do
    subject { described_class.new(participatory_space_private_user, user) }

    let(:organization) { create :organization }
    # let(:privatable_to) { create :participatory_process }
    let(:user) { create :user, :admin, :confirmed, organization: }
    let(:participatory_space_private_user) { create :participatory_space_private_user, user: }

    it "destroys the participatory space private user" do
      subject.call
      expect { participatory_space_private_user.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "broadcasts ok" do
      expect do
        subject.call
      end.to broadcast(:ok)
    end

    it "traces the action", versioning: true do
      expect(Decidim.traceability)
        .to receive(:perform_action!)
        .with(
          "delete",
          participatory_space_private_user,
          user,
          resource: { title: user.name }
        )
        .and_call_original

      expect { subject.call }.to change(Decidim::ActionLog, :count)
      action_log = Decidim::ActionLog.last
      expect(action_log.version).to be_nil
    end
  end
end
