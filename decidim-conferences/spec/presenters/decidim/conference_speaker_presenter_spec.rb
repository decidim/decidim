# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ConferenceSpeakerPresenter, type: :helper do
    let(:conference) { create(:conference) }
    let(:conference_speaker) do
      build(:conference_speaker, full_name:, conference:, user:)
    end
    let(:full_name) { "Full name" }
    let(:user) { nil }

    describe "name" do
      subject { described_class.new(conference_speaker).name }

      it { is_expected.to eq "Full name" }

      context "when speaker is an existing user" do
        let(:user) { create(:user, :confirmed, organization: conference.organization) }

        it { is_expected.to eq user.name }

        context "when the name has special characters" do
          before { user.update_attribute(:name, "<script>alert('test')</script>") } # rubocop:disable Rails/SkipsModelValidations

          it { is_expected.to eq "alert('test')" }
        end

        context "when the user is not visible on the website" do
          let(:user) { create(:user, organization: conference.organization) }

          it { is_expected.to eq full_name }
        end
      end

      context "when speaker is not attached to existing user" do
        let(:user) { nil }

        it { is_expected.to eq full_name }

        context "when the name has special characters" do
          let(:full_name) { "<script>alert('test')</script>" }

          it { is_expected.to eq "alert('test')" }
        end
      end
    end

    describe "nickname" do
      subject { described_class.new(conference_speaker).nickname }

      it { is_expected.to be_nil }

      context "when speaker is an existing user" do
        let(:user) { build(:user, :confirmed, name: "Julia G.", nickname: "julia_g", organization: conference.organization) }
        let(:conference_speaker) { build(:conference_speaker, full_name: "Full name", user:) }

        it { is_expected.to eq "@julia_g" }
      end
    end
  end
end
