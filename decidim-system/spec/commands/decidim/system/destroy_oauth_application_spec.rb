# frozen_string_literal: true

require "spec_helper"

module Decidim::System
  describe DestroyOAuthApplication do
    subject { described_class.new(application, user) }

    let(:application) { create(:oauth_application) }
    let(:user) { create(:user, organization: application.organization) }

    it "destroys the application" do
      subject.call
      expect(Decidim::OAuthApplication.where(id: application.id)).not_to exist
    end

    it "broadcasts :ok" do
      expect { subject.call }.to broadcast(:ok)
    end

    it "logs the action", versioning: true do
      expect(Decidim.traceability)
        .to receive(:perform_action!)
        .with("delete", application, user)
        .and_call_original

      expect { subject.call }.to change(Decidim::ActionLog, :count)

      action_log = Decidim::ActionLog.last
      expect(action_log.version).to be_present
      expect(action_log.version.event).to eq "destroy"
    end
  end
end
