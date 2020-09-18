# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::Election do
  subject(:election) { build(:election) }

  it { is_expected.to be_valid }

  include_examples "has component"
  include_examples "resourceable"
  include_examples "publicable"

  describe "check the log result" do
    it "overwrites the log presenter" do
      expect(described_class.log_presenter_class_for(:foo))
        .to eq Decidim::Elections::AdminLog::ElectionPresenter
    end
  end

  it { is_expected.not_to be_started }
  it { is_expected.not_to be_ongoing }
  it { is_expected.not_to be_finished }

  it "has an association with one questionnaire" do
    subject.questionnaire = build_stubbed(:questionnaire)
    expect(subject.questionnaire).to be_present
  end

  context "when it is ongoing" do
    subject(:election) { build :election, :ongoing }

    it { is_expected.to be_started }
    it { is_expected.to be_ongoing }
    it { is_expected.not_to be_finished }
  end

  context "when it is finished" do
    subject(:election) { build :election, :finished }

    it { is_expected.to be_started }
    it { is_expected.not_to be_ongoing }
    it { is_expected.to be_finished }
  end
end
