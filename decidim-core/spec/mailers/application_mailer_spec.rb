# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Decidim::Dev::DummyResourceMailer do
    describe "smtp_settings" do
      let(:user) { create(:user, organization:) }
      let(:organization) { create(:organization, name: { en: "My Organization" }, smtp_settings:) }
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

      context "when smtp settings has blank values" do
        let(:smtp_settings) do
          {
            "address" => "",
            "port" => "",
            "user_name" => "",
            "encrypted_password" => "",
            "from_email" => "",
            "from_label" => "",
            "from" => ""
          }
        end

        it "returns default values" do
          expect(mail.from).to eq(["change-me@example.org"])
          expect(mail.delivery_method.settings).to be_blank
        end

        context "and from is set" do
          let(:smtp_settings) do
            {
              "address" => "",
              "port" => "",
              "user_name" => "",
              "encrypted_password" => "",
              "from_email" => "",
              "from_label" => "",
              "from" => "Custom <custom@example.org>"
            }
          end

          it "set default values for mail.from and mail.reply_to" do
            expect(mail.header[:from].value).to eq("Custom <custom@example.org>")
            expect(mail.delivery_method.settings).to be_blank
          end
        end
      end

      context "when from is not set" do
        let(:from) { nil }

        before do
          allow(Decidim.config).to receive(:mailer_sender).and_return(mailer_sender)
        end

        context "when the mailer_sender config_accessor does not have a name" do
          let(:mailer_sender) { "changed@example.org" }

          it "uses this email" do
            expect(mail.from).to eq(["changed@example.org"])
          end

          it "returns the organization with the name" do
            expect(mail.header[:from].value).to eq("My Organization <changed@example.org>")
          end
        end

        context "when the mailer_sender config_accessor has a name" do
          let(:mailer_sender) { "ACME <changed@example.org>" }

          it "uses this email" do
            expect(mail.from).to eq(["changed@example.org"])
          end

          it "returns the name defined in the mailer_sender" do
            expect(mail.header[:from].value).to eq("ACME <changed@example.org>")
          end
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
