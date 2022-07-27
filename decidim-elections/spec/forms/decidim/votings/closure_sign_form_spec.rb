# frozen_string_literal: true

require "spec_helper"

describe Decidim::Votings::ClosureSignForm do
  subject { described_class.from_params(attributes) }

  let(:closure) { create :ps_closure, :with_results }
  let(:signed) { true }

  let(:attributes) do
    {
      signed:
    }
  end

  it { is_expected.to be_valid }

  describe "when signed is missing" do
    let(:signed) { nil }

    it { is_expected.to be_invalid }
  end
end
