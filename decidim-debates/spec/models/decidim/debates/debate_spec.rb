# frozen_string_literal: true

require "spec_helper"

describe Decidim::Debates::Debate do
  subject { debate }

  let(:debate) { build(:debate) }
  let(:organization) { debate.component.organization }

  it { is_expected.to be_valid }
  it { is_expected.to be_versioned }
  it { is_expected.to act_as_paranoid }

  include_examples "likeable"
  include_examples "has component"
  include_examples "has taxonomies"
  include_examples "resourceable"
  include_examples "has comments availability attributes"

  describe "newsletter participants" do
    subject { Decidim::Debates::Debate.newsletter_participant_ids(debate.component) }

    let!(:component_out_of_newsletter) { create(:debates_component, organization:) }
    let!(:resource_out_of_newsletter) { create(:debate, component: component_out_of_newsletter) }
    let!(:resource_in_newsletter) { create(:debate, component: debate.component) }
    let(:author_ids) { [] }

    include_examples "counts commentators as newsletter participants"
  end

  context "without a title" do
    let(:debate) { build(:debate, title: nil) }

    it { is_expected.not_to be_valid }
  end

  describe "official?" do
    context "when no author is set" do
      it { is_expected.to be_official }
    end

    context "when author is set" do
      let(:debate) { build(:debate, :participant_author) }

      it { is_expected.not_to be_official }
    end
  end

  describe "ama?" do
    context "when it has both start_time and end_time set" do
      let(:debate) { build(:debate, :open_ama) }

      it { is_expected.to be_ama }
    end

    context "when it does not have both start_time and end_time set" do
      let(:debate) { build(:debate, :open_ama, end_time: nil) }

      it { is_expected.not_to be_ama }
    end
  end

  describe "open_ama?" do
    context "when it is not an AMA debate" do
      before do
        allow(debate).to receive(:ama?).and_return(false)
      end

      it { is_expected.not_to be_open_ama }
    end

    context "when it is an AMA debate" do
      context "when current time is between the range" do
        let(:debate) { build(:debate, start_time: 1.day.ago, end_time: 1.day.from_now) }

        it { is_expected.to be_open_ama }
      end

      context "when current time is not between the range" do
        let(:debate) { build(:debate, start_time: 1.day.from_now, end_time: 2.days.from_now) }

        it { is_expected.not_to be_open_ama }
      end
    end
  end

  describe "accepts_new_comments?" do
    subject { debate.accepts_new_comments? }

    context "when the debate time has ended" do
      let(:debate) { build(:debate, start_time: 2.days.ago, end_time: 1.day.ago) }

      it { is_expected.to be_falsey }
    end

    context "when comments are disabled" do
      before do
        allow(debate).to receive(:commentable?).and_return(false)
      end

      it { is_expected.to be_falsey }
    end

    context "when comments are enabled" do
      let(:debate) { build(:debate, :participant_author) }

      before do
        allow(debate).to receive(:commentable?).and_return(true)
      end

      context "and comments are blocked" do
        before do
          allow(debate)
            .to receive(:comments_blocked?).and_return(true)
        end

        it { is_expected.to be_falsey }
      end

      context "and comments are not blocked" do
        before do
          allow(debate)
            .to receive(:comments_blocked?).and_return(false)
        end

        it { is_expected.to be_truthy }
      end
    end

    context "when the debate has been closed" do
      let(:debate) { build(:debate, :participant_author, :closed) }

      it { is_expected.to be_falsey }
    end
  end
end
