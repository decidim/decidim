# frozen_string_literal: true

require "spec_helper"

describe Decidim::Amendment do
  subject { amendment }

  let(:amendment) { build(:amendment) }

  it { is_expected.to be_valid }

  describe "presence" do
    context "without amender" do
      let(:amendment) { build(:amendment, amender: nil) }

      it { is_expected.not_to be_valid }
    end

    context "without amendable" do
      let(:amendment) { build(:amendment, amendable: nil) }

      it { is_expected.not_to be_valid }
    end

    context "without emendation" do
      let(:amendment) { build(:amendment, emendation: nil) }

      it { is_expected.not_to be_valid }
    end
  end
end
