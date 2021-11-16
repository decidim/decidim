# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe ConferenceSpeakerCell, type: :cell do
    controller Decidim::Conferences::ConferencesController

    context "when rendering a speaker without a user" do
      let!(:conference) { create(:conference) }
      let(:conference_speaker) { create(:conference_speaker, conference: conference) }
      let(:model) { Decidim::ConferenceSpeakerPresenter.new(conference_speaker) }

      it "renders the card" do
        html = cell("decidim/conferences/conference_speaker", model).call
        expect(html).to have_css(".conference-speaker")
      end
    end

    context "when rendering a speaker with an avatar" do
      let!(:conference) { create(:conference) }
      let(:conference_speaker) { create(:conference_speaker, :with_avatar, conference: conference) }
      let(:model) { Decidim::ConferenceSpeakerPresenter.new(conference_speaker) }

      it "renders the card" do
        html = cell("decidim/conferences/conference_speaker", model).call
        expect(html).to have_css(".conference-speaker")
      end
    end

    context "when rendering a speaker with a user" do
      let!(:conference) { create(:conference) }
      let(:conference_speaker) { create(:conference_speaker, :with_user, conference: conference) }
      let(:model) { Decidim::ConferenceSpeakerPresenter.new(conference_speaker) }

      it "renders the card" do
        html = cell("decidim/conferences/conference_speaker", model).call
        expect(html).to have_css(".conference-speaker")
      end
    end
  end
end
