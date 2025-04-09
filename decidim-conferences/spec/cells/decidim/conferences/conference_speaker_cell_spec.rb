# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe ConferenceSpeakerCell, type: :cell do
    controller Decidim::Conferences::ConferencesController

    context "when rendering a speaker without a user" do
      let(:conference_speaker) { create_speaker_with_trait(nil) }
      let(:model) { Decidim::ConferenceSpeakerPresenter.new(conference_speaker) }

      subject { cell("decidim/conferences/conference_speaker", model).call }

      it "renders the card" do
        expect(subject).to have_css("[data-conference-speaker]")
      end
    end

    context "when rendering a speaker with an avatar" do
      let(:conference_speaker) { create_speaker_with_trait(:with_avatar) }
      let(:model) { Decidim::ConferenceSpeakerPresenter.new(conference_speaker) }

      subject { cell("decidim/conferences/conference_speaker", model).call }

      it "renders the card" do
        expect(subject).to have_css("[data-conference-speaker]")
      end
    end

    context "when rendering a speaker with a user" do
      let(:conference_speaker) { create_speaker_with_trait(:with_user) }
      let(:model) { Decidim::ConferenceSpeakerPresenter.new(conference_speaker) }

      subject { cell("decidim/conferences/conference_speaker", model).call }

      it "renders the card" do
        expect(subject).to have_css("[data-conference-speaker]")
      end
    end

    private

    def create_speaker_with_trait(trait)
      create(:conference_speaker, trait)
    end
  end
end
