# frozen_string_literal: true

require "spec_helper"
require "zip"

module Decidim
  # Define a fake mailer class to test its ancestor : ApplicationMailer
  class FakeMailer < ApplicationMailer
    def fake_mail(user)
      @user = user
      @organization = user.organization

      mail(to: "#{user.name} <#{user.email}>") do |format|
        format.text { "This is the test" }
        format.html { "<p>This is a mail </p>" }
      end
    end
  end

  describe FakeMailer, type: :mailer do
    describe "smtp_settings" do
      context "when smtp_settings are not setted" do
        let(:user) { create(:user, name: "Sarah Connor", organization: organization) }
        let!(:organization) do
          create(
            :organization,
            smtp_settings: {
              address: "mail.gotham.gov",
              port: "25",
              user_name: "f.laguardia",
              password: Decidim::AttributeEncryptor.encrypt("password"),
              from_email: "",
              from_label: ""
            }
          )
        end
        let(:mail) { described_class.fake_mail(user) }

        it "set default values for mail.from and mail.reply_to" do
          # byebug
          expect(mail.from).to eq(["change-me@example.org"])
          expect(mail.reply_to).to eq(["change-me@example.org"])
        end
      end

      context "when smtp_settings are not setted" do
        let(:user) { create(:user, name: "Sarah Connor", organization: organization) }
        let!(:organization) do
          create(
            :organization,
            smtp_settings: {
              address: "mail.gotham.gov",
              port: "25",
              user_name: "f.laguardia",
              password: Decidim::AttributeEncryptor.encrypt("password"),
              from_email: "decide@gotham.org",
              from_label: "Bruce Wayne"
            }
          )
        end
        let(:mail) { described_class.fake_mail(user) }

        it "set default values for mail.from and mail.reply_to" do
          # byebug
          expect(mail.from).to eq(["change-me@example.org"])
          expect(mail.reply_to).to eq(["change-me@example.org"])
        end
      end
    end
  end
end
