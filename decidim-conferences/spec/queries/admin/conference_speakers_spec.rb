# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences::Admin
  describe ConferenceSpeakers do
    subject { described_class.for(Decidim::ConferenceSpeaker.all, search) }

    let(:organization) { create :organization }
    let(:search) { nil }

    describe "when the list is not filtered" do
      let!(:conference_speakers) { create_list(:conference_speaker, 3) }

      it "returns all the conference speakers" do
        expect(subject).to match_array(conference_speakers)
      end
    end

    describe "when the list is filtered" do
      context "and receives a search param" do
        let(:conference_speakers) do
          %w(Walter Fargo Phargo).map do |name|
            create(:conference_speaker, full_name: name)
          end
        end

        context "with regular characters" do
          let(:search) { "Argo" }

          it "returns all matching conference speakers" do
            expect(subject).to match_array([conference_speakers[1], conference_speakers[2]])
          end
        end

        context "with conflictive characters" do
          let(:search) { "Andy O'Connel" }

          it "returns all matching users" do
            expect(subject).to be_empty
          end
        end
      end
    end
  end
end
