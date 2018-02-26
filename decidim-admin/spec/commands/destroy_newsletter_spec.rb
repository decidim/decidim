# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe DestroyNewsletter do
    subject { described_class.new(newsletter, user) }

    let(:newsletter) { create(:newsletter) }
    let(:user) { create(:user, organization: newsletter.organization) }

    context "when the newsletter is already sent" do
      let(:newsletter) { create :newsletter, :sent }

      it "does not destroy the newsletter" do
        subject.call
        expect(Decidim::Newsletter.where(id: newsletter.id)).to exist
      end

      it "broadcasts :already_sent" do
        expect { subject.call }.to broadcast(:already_sent)
      end
    end

    context "when everything is ok" do
      it "destroys the newsletter" do
        subject.call
        expect(Decidim::Newsletter.where(id: newsletter.id)).not_to exist
      end

      it "broadcasts :ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "logs the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with("delete", newsletter, user)
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)

        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
        expect(action_log.version.event).to eq "destroy"
      end
    end
  end
end
