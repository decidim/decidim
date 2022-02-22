# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe ConferenceSpeakerCell, type: :cell do
    controller Decidim::Conferences::ConferencesController

    context "when rendering a speaker without a user" do
      let(:conference_speaker) { create_speaker_with_trait(nil) }
      let(:model) { Decidim::ConferenceSpeakerPresenter.new(conference_speaker) }

      it "renders the card" do
        call_and_expect_speaker_cell(model)
      end
    end

    context "when rendering a speaker with an avatar" do
      let(:conference_speaker) { create_speaker_with_trait(:with_avatar) }
      let(:model) { Decidim::ConferenceSpeakerPresenter.new(conference_speaker) }

      it "renders the card" do
        call_and_expect_speaker_cell(model)
      end
    end

    context "when rendering a speaker with a user" do
      let(:conference_speaker) { create_speaker_with_trait(:with_user) }
      let(:model) { Decidim::ConferenceSpeakerPresenter.new(conference_speaker) }

      it "renders the card" do
        call_and_expect_speaker_cell(model)
      end
    end

    private

    def create_speaker_with_trait(trait)
      create(:conference_speaker, trait)
    end

    def call_and_expect_speaker_cell(model)
      html = cell("decidim/conferences/conference_speaker", model).call
      expect(html).to have_css(".conference-speaker")
    end
  end
end
