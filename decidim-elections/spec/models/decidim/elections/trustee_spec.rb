# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Trustee do
  subject(:trustee) { build(:trustee) }

  it { is_expected.to be_valid }

  context "when it is considered" do
    subject(:trustee) { build :trustee, :considered }

    it { is_expected.to be_valid }
  end
end
