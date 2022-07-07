# frozen_string_literal: true

require "spec_helper"

shared_examples "localised email" do
  let(:user) { build(:user, locale: locale) }

  context "when the user has a custom locale" do
    let(:locale) { "ca" }

    it "uses the user's locale" do
      expect(mail.subject).to eq(mail_subject)
      expect(mail.body.encoded).to match(body)
    end
  end

  context "when the user does not have a custom locale" do
    let(:locale) { nil }

    it "uses the default locale" do
      expect(mail.subject).to eq(default_subject)
      expect(mail.body.encoded).to match(default_body)
    end
  end

  context "when the user doesn't have an email" do
    let(:user) { create(:user, :deleted) }

    it "does nothing" do
      expect(mail.deliver_now).to be_nil
    end
  end
end
