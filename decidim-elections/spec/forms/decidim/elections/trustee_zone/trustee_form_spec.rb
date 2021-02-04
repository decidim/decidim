# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::TrusteeZone::TrusteeForm do
  subject { described_class.from_params(attributes).with_context(context) }

  let(:trustee) { create(:trustee, public_key: public_key) }
  let(:public_key) { nil }
  let(:trustee_name) { "Shelton Runolfsson Sr." }
  let(:new_public_key) { "1234567890abcde" }
  let(:attributes) do
    {
      public_key: new_public_key,
      name: trustee_name
    }
  end
  let(:context) do
    {
      trustee: trustee
    }
  end

  it { is_expected.to be_valid }

  context "when the new public_key is missing" do
    let(:new_public_key) { "" }

    it { is_expected.not_to be_valid }
  end

  context "when the trustee already has a public key" do
    let(:public_key) { "1234567890abcde" }

    it { is_expected.not_to be_valid }
  end

  context "when the trustee already has a name" do
    let(:trustee) { create(:trustee, public_key: public_key, name: "Sheldon") }

    it { is_expected.not_to be_valid }
  end
end
