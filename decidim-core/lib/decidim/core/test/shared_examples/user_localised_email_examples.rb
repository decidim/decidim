# frozen_string_literal: true

require "spec_helper"

shared_examples "user localised email" do
  let(:user) { create(:user, locale: locale, organization: organization) }

  context "when the user has a custom locale" do
    let(:locale) { "ca" }

    it "uses the user's locale" do
      expect(mail.subject).to eq(subject)
      expect(mail.body.encoded).to match(body)
    end
  end

  context "otherwise" do
    let(:locale) { nil }

    it "uses the default locale" do
      expect(mail.subject).to eq(default_subject)
      expect(mail.body.encoded).to match(default_body)
    end
  end
end
