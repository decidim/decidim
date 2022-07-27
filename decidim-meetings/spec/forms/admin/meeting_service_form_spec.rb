# frozen_string_literal: true

require "spec_helper"
require "decidim/dev/test/form_to_param_shared_examples"

module Decidim::Meetings
  describe Admin::MeetingServiceForm do
    subject(:form) do
      described_class.from_params(
        attributes
      ).with_context(current_organization: organization)
    end

    let(:organization) { create :organization }

    let(:title) { Decidim::Faker::Localized.sentence(word_count: 3) }
    let(:description) { Decidim::Faker::Localized.sentence(word_count: 3) }
    let(:deleted) { false }

    let(:attributes) do
      {
        title_en: title[:en],
        description_en: description[:en],
        deleted:
      }
    end

    it { is_expected.to be_valid }

    describe "when title is missing" do
      let(:title) { { en: nil } }

      it { is_expected.not_to be_valid }

      context "and service is deleted" do
        let(:deleted) { true }

        it { is_expected.to be_valid }
      end
    end

    it_behaves_like "form to param", default_id: "meeting-service-id"
  end
end
