# frozen_string_literal: true

require "spec_helper"

describe Decidim::ResendConfirmationInstructionsJob do
  let(:user) { create(:user) }

  describe "#perform" do
    subject { described_class.new.perform(user) }

    it "calls method on resources" do
      perform_enqueued_jobs { subject }

      expect(last_email.subject).to eq("Confirmation instructions")
      expect(last_email.to).to eq([user.email])
    end
  end
end
