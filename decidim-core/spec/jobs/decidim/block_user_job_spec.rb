# frozen_string_literal: true

require "spec_helper"

describe Decidim::BlockUserJob do
  describe "#perform" do
    subject { described_class.new.perform(user, justification) }

    let(:user) { create(:user, :blocked) }
    let(:justification) { "This user was spamming too much." }

    it "sends the block notification" do
      perform_enqueued_jobs { subject }

      expect(last_email.to).to eq([user.email])
      expect(last_email.subject).to eq("Your account was blocked by #{user.organization.name}")
      expect(last_email_body).to include("Your account was blocked.")
      expect(last_email_body).to include("Reason: #{justification}")
    end
  end
end
