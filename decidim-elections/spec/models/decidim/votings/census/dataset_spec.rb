# frozen_string_literal: true

require "spec_helper"

describe Decidim::Votings::Census::Dataset do
  subject { dataset }

  let(:dataset) { build(:dataset) }

  it { is_expected.to be_valid }
  it { is_expected.to be_versioned }

  it "overwrites the log presenter" do
    expect(described_class.log_presenter_class_for(:foo))
      .to eq Decidim::Votings::Census::AdminLog::DatasetPresenter
  end

  it "has an associated voting" do
    expect(dataset.voting).to be_a(Decidim::Votings::Voting)
  end

  context "without file" do
    let(:dataset) { build(:dataset, filename: nil) }

    it { is_expected.not_to be_valid }
  end
end
