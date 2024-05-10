# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Decidim::Dev::DummyResourceMailer do
    describe "smtp_settings" do
      let(:user) { create(:user, organization:) }
      let(:organization) { create(:organization, name: "My Organization", smtp_settings:) }
      let(:smtp_settings) do
        {
          "address" => "mail.example.org",
          "port" => "25",
          "user_name" => "f.laguardia",
          "encrypted_password" => Decidim::AttributeEncryptor.encrypt("password"),
          "from_email" => "",
          "from_label" => "",
          "from" => from
        }
      end
      let(:mail) { described_class.send_email(user, organization, mail_subject, reply_to) }
      let(:from) { "" }
      let(:reply_to) { nil }
      let(:mail_subject) { "Test subject" }

      it "update correctly mail.delivery_method.settings" do
        expect(mail.delivery_method.settings[:address]).to eq("mail.example.org")
        expect(mail.delivery_method.settings[:port]).to eq("25")
        expect(mail.delivery_method.settings[:user_name]).to eq("f.laguardia")
        expect(mail.delivery_method.settings[:password]).to eq("password")
      end

      context "when there is no organization at all" do
        let(:mail) { described_class.send_email(user, nil, mail_subject, reply_to) }

        it "returns default values" do
          expect(mail.from).to eq(["change-me@example.org"])
          expect(mail.reply_to).to be_nil
          expect(mail.subject).to eq(mail_subject)
        end
      end

      context "when smtp_settings are not set" do
        let(:smtp_settings) { nil }

        it "returns default values" do
          expect(mail.from).to eq(["change-me@example.org"])
        end

        it "returns the organization with the name" do
          expect(mail.header[:from].value).to eq("My Organization <change-me@example.org>")
        end
      end

      context "when from is not set" do
        let(:from) { nil }

        it "set default values for mail.from" do
          expect(mail.from).to eq(["change-me@example.org"])
        end
      end

      context "when from is set with a name" do
        let(:from) { "Bruce Wayne <decide@gotham.org>" }

        it "set default values for mail.from and mail.reply_to" do
          expect(mail.from).to eq(["decide@gotham.org"])
        end

        it "returns the organization with the name" do
          expect(mail.header[:from].value).to eq("Bruce Wayne <decide@gotham.org>")
        end
      end

      context "when from is set without a name" do
        let(:from) { "decide@gotham.org" }

        it "set default values for mail.from and mail.reply_to" do
          expect(mail.from).to eq(["decide@gotham.org"])
        end

        it "returns the organization with the name" do
          expect(mail.header[:from].value).to eq("My Organization <decide@gotham.org>")
        end
      end

      context "when reply_to is set" do
        let(:reply_to_address) { "villain@gotham.org" }
        let(:reply_to) { "Arthur Fleck <#{reply_to_address}>" }

        it "set given reply_to" do
          expect(mail.reply_to).to eq([reply_to_address])
        end
      end

      context "when reply_to is unset" do
        it "uses default config" do
          expect(mail.from).to eq(["change-me@example.org"])
        end
      end

      context "when subject is set" do
        let(:mail_subject) { "Custom subject" }

        it "sets subject" do
          expect(mail.subject).to eq("Custom subject")
        end
      end
    end
  end
end
