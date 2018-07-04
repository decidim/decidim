# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ConferenceSpeaker do
    subject { conference_speaker }

    let(:conference_speaker) { build(:conference_speaker) }

    it { is_expected.to be_valid }
    it { is_expected.to be_versioned }

    describe ".default_scope" do
      it "returns speakers ordered by name" do
        conference_speaker1 = create(:conference_speaker, full_name: "Speaker 3")
        conference_speaker2 = create(:conference_speaker, full_name: "Speaker 1")
        conference_speaker3 = create(:conference_speaker, full_name: "Speaker 2")

        expected_result = [
          conference_speaker2,
          conference_speaker3,
          conference_speaker1
        ]

        expect(described_class.all).to eq expected_result
      end
    end

    describe "#participatory_space" do
      it "is an alias for #conference" do
        expect(conference_speaker.conference).to eq conference_speaker.participatory_space
      end
    end
  end
end
