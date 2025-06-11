# frozen_string_literal: true

require "spec_helper"

describe Decidim::Ai::SpamDetection::GenericSpamAnalyzerJob do
  subject { described_class }

  let!(:organization_one) { create(:organization) }
  let!(:organization_two) { create(:organization) }
  let!(:user_one) { create(:user, email: reporting_user_email, organization: organization_one) }
  let!(:user_two) { create(:user, email: reporting_user_email, organization: organization_two) }
  let(:reporting_user_email) { "reporting@example.org" }

  describe "queue" do
    it "is queued to spam_analysis" do
      expect(subject.queue_name).to eq "spam_analysis"
    end
  end

  describe "#reporting_user" do
    before do
      allow(Decidim::Ai::SpamDetection).to receive(:reporting_user_email).and_return(reporting_user_email)
    end

    it "finds the user by email" do
      obj = subject.new
      obj.instance_variable_set(:@organization, organization_two)
      expect(obj.send(:reporting_user)).to eq user_two
    end
  end
end
