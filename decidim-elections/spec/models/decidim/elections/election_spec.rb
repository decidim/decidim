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
        .to eq Decidim::AdminLog::ElectionPresenter
    end
  end

  describe "started?" do
    it { is_expected.not_to be_started }

    context "when it is started" do
      subject(:election) { build :election, :started }

      it { is_expected.to be_started }
    end
  end

  describe "finished?" do
    it { is_expected.not_to be_finished }

    context "when it is finished" do
      subject(:election) { build :election, :finished }

      it { is_expected.to be_finished }
    end
  end
end
