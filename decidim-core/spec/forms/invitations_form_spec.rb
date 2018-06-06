# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe InvitationsForm do
    subject do
      described_class.new(
        email_1: email_1,
        email_2: email_2,
        email_3: email_3,
        email_4: email_4,
        email_5: email_5,
        email_6: email_6,
        custom_message: custom_message
      ).with_context(
        current_organization: organization,
        current_user: user
      )
    end

    let(:user) { create(:user) }
    let(:organization) { user.organization }

    let(:email_1) { "email_1@example.org" }
    let(:email_2) { "email_2@example.org" }
    let(:email_3) { "email_3@example.org" }
    let(:email_4) { "email_4@example.org" }
    let(:email_5) { "email_5@example.org" }
    let(:email_6) { "email_6@example.org" }
    let(:custom_message) { "Come to Decidim!" }

    context "with correct data" do
      it { is_expected.to be_valid }
    end

    context "with an empty email" do
      let(:email_1) { "" }

      it { is_expected.to be_valid }
    end

    context "with a null email" do
      let(:email_1) { nil }

      it { is_expected.to be_valid }
    end

    context "with an badly-formatted email" do
      let(:email_1) { "this is not an email" }

      it { is_expected.not_to be_valid }
    end

    context "when emails are blank" do
      let(:email_1) { "" }
      let(:email_2) { "" }
      let(:email_3) { "" }
      let(:email_4) { "" }
      let(:email_5) { "" }
      let(:email_6) { "" }

      it { is_expected.not_to be_valid }
    end

    describe "emails" do
      let(:email_3) { nil }
      let(:email_4) { "" }
      let(:email_5) { email_1 }
      let(:email_6) { email_1 }

      it "only considers unique and present emails" do
        expect(subject.emails).to match_array([email_1, email_2])
      end
    end

    describe "emails" do
      let(:external_user) { create :user, email: "another_email@bar.com"}
      let(:email_2) { user.email }
      let(:email_3) { nil }
      let(:email_4) { "" }
      let(:email_5) { email_1 }
      let(:email_6) { external_user.email }

      it "only considers unique and present emails" do
        expect(subject.clean_emails).to match_array([email_1, email_6])
      end
    end
  end
end
