# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::TrusteeZone::TrusteeForm do
  subject { described_class.from_params(attributes) }

  let(:public_key) { "1234567890abcde" }
  let(:attributes) do
    {
      public_key: public_key
    }
  end

  it { is_expected.to be_valid }

  describe "when public_key is missing" do
    let(:public_key) { "" }

    it { is_expected.not_to be_valid }
  end
end
