# frozen_string_literal: true

require "spec_helper"

describe Decidim::Admin::FakeNewsletter do
  subject { newsletter }

  let(:newsletter) { described_class.new(organization, manifest) }
  let(:organization) { create(:organization) }
  let(:manifest) do
    Decidim
      .content_blocks
      .for(:newsletter_template)
      .find { |manifest| manifest.name.to_s == "basic_only_text" }
  end

  describe "sent_at" do
    it "is nil" do
      expect(subject.sent_at).to be_nil
    end
  end

  describe "id" do
    it "is 1" do
      expect(subject.id).to eq(1)
    end
  end

  describe "template" do
    it "builds a content block with preview data" do
      expect(subject.template).to be_a(Decidim::ContentBlock)
      expect(subject.template).not_to be_persisted
      expect(subject.template.settings.body).to include("Dummy text for body")
    end
  end

  describe "#url" do
    subject { newsletter.url }

    it { is_expected.to eq("#") }
  end

  describe "#notifications_settings_url" do
    subject { newsletter.notifications_settings_url }

    it { is_expected.to eq("#") }
  end

  describe "#unsubscribe_newsletters_url" do
    subject { newsletter.unsubscribe_newsletters_url }

    it { is_expected.to eq("#") }
  end

  describe "#organization_official_url" do
    subject { newsletter.organization_official_url }

    it { is_expected.to eq("#") }
  end
end
