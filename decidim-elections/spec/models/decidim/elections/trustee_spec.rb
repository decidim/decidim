# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Trustee do
  subject { trustee }

  let(:trustee) { build(:trustee, name: "Trustee 1") }
  let(:organization) { trustee.organization }

  it { is_expected.to be_valid }

  it { expect(subject.bulletin_board_slug).to eql("#{organization.name.parameterize}-trustee-1") }

  context "when it is considered" do
    let(:trustee) { build(:trustee, :considered) }

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
