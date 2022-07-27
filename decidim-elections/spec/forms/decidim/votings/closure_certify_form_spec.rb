# frozen_string_literal: true

require "spec_helper"

describe Decidim::Votings::ClosureCertifyForm do
  subject { described_class.from_params(params).with_context(closure:) }

  let(:closure) { create :ps_closure, :with_results, phase: }
  let(:phase) { :certificate }
  let(:add_photos) { [Decidim::Dev.test_file("city.jpeg", "image/jpeg")] }
  let(:params) do
    {
      add_photos:
    }
  end

  it { is_expected.to be_valid }

  describe "when attachment is missing" do
    let(:add_photos) { nil }

    it { is_expected.to be_invalid }
  end

  describe "when closure is not in certificate phase" do
    let(:phase) { :results }

    it { is_expected.to be_invalid }
  end
end
