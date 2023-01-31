# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Newsletter do
    subject { newsletter }

    let(:newsletter) { build(:newsletter) }

    it { is_expected.to be_versioned }

    it "overwrites the log presenter" do
      expect(described_class.log_presenter_class_for(:foo))
        .to eq Decidim::AdminLog::NewsletterPresenter
    end

    describe "validations" do
      it "is valid" do
        expect(subject).to be_valid
      end

      it "is not valid without a subject" do
        newsletter.subject = nil

        expect(subject).not_to be_valid
      end

      it "is not valid if author is from another organization" do
        user = build :user, organization: build(:organization)
        newsletter = build :newsletter, organization: build(:organization), author: user

        expect(newsletter).not_to be_valid
      end
    end

    describe "#url" do
      subject { newsletter.url }

      let(:newsletter) { create(:newsletter) }
      let(:organization) { newsletter.organization }

      it { is_expected.to eq("http://#{organization.host}:#{Capybara.server_port}/newsletters/#{newsletter.id}") }
    end

    describe "#notifications_settings_url" do
      subject { newsletter.notifications_settings_url }

      let(:newsletter) { create(:newsletter) }
      let(:organization) { newsletter.organization }

      it { is_expected.to eq("http://#{organization.host}:#{Capybara.server_port}/notifications_settings") }
    end

    describe "#unsubscribe_newsletters_url" do
      subject { newsletter.unsubscribe_newsletters_url }

      let(:newsletter) { create(:newsletter) }
      let(:organization) { newsletter.organization }

      it { is_expected.to eq("http://#{organization.host}:#{Capybara.server_port}/newsletters/unsubscribe") }
    end
  end
end
