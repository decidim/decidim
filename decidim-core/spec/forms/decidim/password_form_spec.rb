# frozen_string_literal: true

require "spec_helper"

describe Decidim::PasswordForm do
  subject do
    described_class.new(
      password:,
      password_confirmation:
    )
  end

  let(:password) { Faker::Internet.password(min_length: 17) }

  context "when passwords match" do
    let(:password_confirmation) { password }

    it "is valid" do
      expect(subject).to be_valid
    end
  end

  context "when passwords doesnt match" do
    let(:password_confirmation) { Faker::Internet.password(min_length: 15, max_length: 16) }

    it "is not valid" do
      expect(subject).not_to be_valid
    end
  end
end
