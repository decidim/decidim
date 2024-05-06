# frozen_string_literal: true

require "spec_helper"

module Decidim
  class DummyAdminResourceMailer < Decidim::Admin::ApplicationMailer
    def send_email(user, organization, subject, reply_to)
      @user = user
      @organization = organization

      hash = { to: "#{user.name} <#{user.email}>" }
      hash[:subject] = subject if subject
      hash[:reply_to] = reply_to if reply_to

      mail(
        hash
      ) do |format|
        format.text { "This is the test" }
        format.html { "<p>This is a mail </p>" }
      end
    end
  end

  describe DummyAdminResourceMailer do
    let(:mail) { described_class.send_email(user, organization, mail_subject, reply_to) }
    let(:user) { create(:user, organization:) }
    let(:reply_to) { nil }
    let(:mail_subject) { "Test subject" }
    let(:organization) { create(:organization, name: "My Organization") }

    context "when sending an email" do
      it "returns default values" do
        expect(mail.from).to eq(["change-me@example.org"])
      end

      it "returns the organization with the name" do
        expect(mail.header[:from].value).to eq("My Organization <change-me@example.org>")
      end
    end
  end
end
