# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Decidim::DummyResources::DummyResourceMailer, type: :mailer do
    describe "smtp_settings" do
      let(:user) { create(:user, organization: organization) }
      let(:organization) { create(:organization, smtp_settings: smtp_settings) }
      let(:smtp_settings) do
        {
          "address" => "mail.gotham.gov",
          "port" => "25",
          "user_name" => "f.laguardia",
          "password" => Decidim::AttributeEncryptor.encrypt("password"),
          "from_email" => "",
          "from_label" => "",
          "from" => from
        }
      end
      let(:mail) { described_class.send_email(user, organization) }
      let(:from) { "" }

      context "when there is no organization at all" do
        let(:mail) { described_class.send_email(user, nil) }

        it "returns default values" do
          expect(mail.from).to eq(["change-me@domain.org"])
          expect(mail.reply_to).to eq(nil)
        end
      end

      context "when smtp_settings are not set" do
        let(:smtp_settings) { nil }

        it "returns default values" do
          expect(mail.from).to eq(["change-me@domain.org"])
          expect(mail.reply_to).to eq(nil)
        end
      end

      context "when from label is not set" do
        let(:from) { nil }

        it "set default values for mail.from and mail.reply_to" do
          expect(mail.from).to eq(["change-me@domain.org"])
          expect(mail.reply_to).to eq(["change-me@domain.org"])
        end
      end

      context "when from label is set" do
        let(:from) { "Bruce Wayne <decide@gotham.org>" }

        it "set default values for mail.from and mail.reply_to" do
          expect(mail.from).to eq(["decide@gotham.org"])
          expect(mail.reply_to).to eq(["decide@gotham.org"])
        end
      end
    end
  end
end
