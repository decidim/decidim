# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    module Admin
      describe MeetingRegistrationInviteForm do
        let(:email) { "foo@example.org" }
        let(:attributes) do
          {
            email: email
          }
        end

        subject { described_class.from_params(attributes) }

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when email is missing" do
          let(:email) {}

          it { is_expected.to be_invalid }
        end
      end
    end
  end
end
