# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe Admin::MinutesForm do
    subject(:form) { described_class.from_params(attributes).with_context(context) }

    let(:organization) { create(:organization, available_locales: [:en]) }
    let(:participatory_process) { create :participatory_process, organization: organization }
    let(:current_component) { create :component, participatory_space: participatory_process, manifest_name: "meetings" }
    let(:meeting) { create :meeting, component: current_component }

    let(:context) do
      {
        current_organization: organization,
        current_component: current_component,
        current_participatory_space: participatory_process,
        meeting: meeting
      }
    end

    let(:description) { Decidim::Faker::Localized.sentence(word_count: 3) }

    let(:video_url) do
      Faker::Internet.url
    end
    let(:audio_url) do
      Faker::Internet.url
    end
    let(:visible) { true }

    let(:attributes) do
      {
        description_en: description[:en],
        video_url: video_url,
        audio_url: audio_url,
        visible: visible
      }
    end

    it { is_expected.to be_valid }

    describe "when description is missing" do
      let(:description) { { en: nil } }

      it { is_expected.not_to be_valid }
    end
  end
end
