# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::TrusteeZone::UpdateTrustee do
  subject { described_class.new(form) }

  let(:trustee) { create :trustee, public_key: nil }
  let(:form) do
    double(
      invalid?: invalid,
      public_key:,
      trustee:,
      name: trustee_name,
      errors:
    )
  end
  let(:public_key) { "asadasfdafadssda" }
  let(:trustee_name) { "Sheldon" }
  let(:invalid) { false }
  let(:errors) { double.as_null_object }

  it "updates the trustee" do
    subject.call
    expect(trustee.public_key).to eq "asadasfdafadssda"
  end

  context "when trustee with same name and organization exists" do
    let!(:other_trustee) { create :trustee, name: "Sheldon", organization: trustee.organization }

    it "adds errors to the form" do
      expect(errors).to receive(:add).with(:name, :taken)
      subject.call
      expect(subject).to broadcast(:invalid)
    end
  end

  context "when the form is not valid" do
    let(:invalid) { true }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
      expect(trustee.public_key).to be_nil
    end
  end
end
