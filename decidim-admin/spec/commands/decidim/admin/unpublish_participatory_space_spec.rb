# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UnpublishParticipatorySpace do
    subject { described_class.new(participatory_space, user) }

    let(:organization) { create :organization }
    let(:user) { create :user, :admin, :confirmed, organization: organization }
    let(:participatory_space) { create :participatory_space, :published, organization: organization }

    it "activates the area" do
      subject.call
      participatory_space.reload
      expect(participatory_space).to be_published
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
          "unpublish",
          participatory_space,
          user,
          manifest_name: participatory_space.manifest_name
        )
        .and_call_original

      expect { subject.call }.to change(Decidim::ActionLog, :count)
      action_log = Decidim::ActionLog.last
      expect(action_log.version).to be_present
    end
  end
end
