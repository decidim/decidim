# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Conferences
    module Admin
      describe MediaLinkForm do
        subject(:form) { described_class.from_params(attributes).with_context(context) }

        let(:organization) { create :organization }
        let(:conference) { create :conference, organization: }
        let(:current_participatory_space) { conference }

        let(:context) do
          {
            current_participatory_space: conference,
            current_organization: organization
          }
        end

        let(:title) { Decidim::Faker::Localized.sentence }
        let(:link) { "http://decidim.org" }
        let(:weight) { 1 }
        let(:date) { 2.days.from_now }
        let(:attributes) do
          {
            "conference_media_link" => {
              "title" => title,
              "link" => link,
              "weight" => weight,
              "date" => date
            }
          }
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when title is missing" do
          let(:title) { nil }

          it { is_expected.to be_invalid }
        end

        context "when date is missing" do
          let(:date) { nil }

          it { is_expected.to be_invalid }
        end

        describe "link" do
          context "when link is missing" do
            let(:link) { nil }

            it { is_expected.to be_invalid }
          end

          context "when it doesn't start with http" do
            let(:link) { "example.org" }

            it "adds it" do
              expect(subject.link).to eq("http://example.org")
            end
          end

          context "when it's not a valid URL" do
            let(:link) { "foobar, aa" }

            it { is_expected.to be_invalid }
          end
        end
      end
    end
  end
end
