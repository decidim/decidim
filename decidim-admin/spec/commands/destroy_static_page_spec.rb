# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe DestroyStaticPage do
    subject { described_class.new(page, user) }

    let!(:page) { create(:static_page) }
    let!(:user) { create(:user, organization: page.organization) }

    context "when everything is ok" do
      it "destroys the page" do
        subject.call
        expect(Decidim::StaticPage.where(id: page.id)).not_to exist
      end

      it "logs the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with("delete", page, user)
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)

        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
        expect(action_log.version.event).to eq "destroy"
      end
    end
  end
end
