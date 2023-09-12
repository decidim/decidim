# frozen_string_literal: true

require "spec_helper"

describe Decidim::PasswordForm do
  subject do
    described_class.new(
      password:
    )
  end

  let(:password) { Faker::Internet.password(min_length: 17, max_length: 20) }

  context "when the password is not present" do
    let(:password) { nil }

    it { is_expected.to be_invalid }
  end
end
