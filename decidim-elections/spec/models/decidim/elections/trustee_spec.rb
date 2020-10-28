# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Trustee do
  subject(:trustee) { build(:trustee) }

  it { is_expected.to be_valid }

  context "when it is considered" do
    subject(:trustee) { build :trustee, :considered }

    it { is_expected.to be_valid }
  end

  describe "class methods" do
    subject { described_class }

    let(:trustee) { create(:trustee) }
    let(:user) { trustee.user }

    before { trustee }

    it { is_expected.to be_trustee(user) }
    it { expect(subject.for(user)).to eq(trustee) }

    context "when the user is not a trustee" do
      let(:user) { create(:user) }

      it { is_expected.not_to be_trustee(user) }
      it { expect(subject.for(user)).to be_nil }
    end
  end
end
