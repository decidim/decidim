# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe ConferenceSpeakerCell, type: :cell do
    controller Decidim::Conferences::ConferencesController
    subject { cell("decidim/conferences/conference_speaker", model).call }

    context "when rendering a speaker without a user" do
      let(:conference_speaker) { create(:conference_speaker) }
      let(:model) { Decidim::ConferenceSpeakerPresenter.new(conference_speaker) }


      it "renders the card" do
        expect(subject).to have_css("[data-conference-speaker]")
      end
    end

    context "when rendering a speaker with an avatar" do
      let(:conference_speaker) { create(:conference_speaker, :with_avatar) }
      let(:model) { Decidim::ConferenceSpeakerPresenter.new(conference_speaker) }

      it "renders the card" do
        expect(subject).to have_css("[data-conference-speaker]")
      end
    end

    context "when rendering a speaker with a user" do
      let(:conference_speaker) { create(:conference_speaker, :with_user) }
      let(:model) { Decidim::ConferenceSpeakerPresenter.new(conference_speaker) }

      it "renders the card" do
        expect(subject).to have_css("[data-conference-speaker]")
      end
    end
  end
end
