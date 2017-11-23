# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe Admin::MeetingRegistrationInviteForm do
    subject { described_class.from_params(attributes) }

    let(:name) { "Foo" }
    let(:email) { "foo@example.org" }
    let(:attributes) do
      {
        name: name,
        email: email
      }
    end

    context "when everything is OK" do
      it { is_expected.to be_valid }
    end

    context "when name is missing" do
      let(:name) {}

      it { is_expected.to be_invalid }
    end

    context "when email is missing" do
      let(:email) {}

      it { is_expected.to be_invalid }
    end
  end
end
