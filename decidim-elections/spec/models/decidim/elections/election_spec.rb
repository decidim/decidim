# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Election do
  subject(:election) { build(:election) }

  it { is_expected.to be_valid }

  include_examples "has component"
  include_examples "resourceable"

  describe "started?" do
    it { is_expected.not_to be_started }

    context "when it is started" do
      subject(:election) { build :election, :started }

      it { is_expected.to be_started }
    end
  end
end
