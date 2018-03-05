# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UnpublishFeature do
    subject { described_class.new(feature, user) }

    let!(:user) { create(:user, :admin, :confirmed, organization: participatory_process.organization) }
    let!(:participatory_process) { create(:participatory_process, :with_steps) }
    let(:step) { participatory_process.steps.first }
    let!(:feature) { create(:feature, :published, participatory_space: participatory_process) }

    it "unpublishes the feature" do
      expect { subject.call }.to change(feature, :published?).from(true).to(false)
    end

    it "traces the action", versioning: true do
      expect(Decidim.traceability)
        .to receive(:perform_action!)
        .with(:unpublish, feature, user)
        .and_call_original

      expect { subject.call }.to change(Decidim::ActionLog, :count)
      action_log = Decidim::ActionLog.last
      expect(action_log.version).to be_present
    end
  end
end
