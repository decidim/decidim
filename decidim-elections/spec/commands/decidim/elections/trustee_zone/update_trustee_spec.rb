# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::TrusteeZone::UpdateTrustee do
  subject { described_class.new(form) }

  let(:trustee) { create :trustee, public_key: nil }
  let(:form) do
    double(
      invalid?: invalid,
      public_key: public_key,
      trustee: trustee
    )
  end
  let(:public_key) { "asadasfdafadssda" }
  let(:invalid) { false }

  it "updates the trustee" do
    subject.call
    expect(trustee.public_key).to eq "asadasfdafadssda"
  end

  context "when the form is not valid" do
    let(:invalid) { true }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
      expect(trustee.public_key).to be_nil
    end
  end
end
