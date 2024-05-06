# frozen_string_literal: true

require "spec_helper"

module Decidim
  class DummySystemResourceMailer < Decidim::System::ApplicationMailer
    def send_email(user_name, user_email, subject, reply_to)
      hash = { to: "#{user_name} <#{user_email}>" }
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

  describe DummySystemResourceMailer do
    let(:mail) { described_class.send_email(user_name, user_email, mail_subject, reply_to) }
    let(:user_name) { "John Doe" }
    let(:user_email) { "john.doe@example.org" }
    let(:reply_to) { nil }
    let(:mail_subject) { "Test subject" }

    context "when sending an email" do
      it "returns default values" do
        expect(mail.from).to eq(["change-me@example.org"])
      end

      it "returns the application name" do
        expect(mail.header[:from].value).to eq("My Application Name <change-me@example.org>")
      end
    end
  end
end
