# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Consultations
    module Admin
      describe ConsultationForm do
        subject { described_class.from_params(attributes).with_context(current_organization: organization) }

        let(:organization) { create :organization }
        let(:scope) { create :scope, organization: }
        let(:title) do
          {
            en: "Title",
            es: "Título",
            ca: "Títol"
          }
        end
        let(:subtitle) do
          {
            en: "Subtitle",
            es: "Subtítulo",
            ca: "Subtítol"
          }
        end
        let(:description) do
          {
            en: "Description",
            es: "Descripción",
            ca: "Descripció"
          }
        end
        let(:slug) { "slug" }
        let(:start_voting_date) { Time.zone.today }
        let(:end_voting_date) { Time.zone.today + 1.month }
        let(:attachment) { upload_test_file(Decidim::Dev.test_file("city2.jpeg", "image/jpeg")) }

        let(:attributes) do
          {
            "consultation" => {
              "title_en" => title[:en],
              "title_es" => title[:es],
              "title_ca" => title[:ca],
              "subtitle_en" => subtitle[:en],
              "subtitle_es" => subtitle[:es],
              "subtitle_ca" => subtitle[:ca],
              "description_en" => description[:en],
              "description_es" => description[:es],
              "description_ca" => description[:ca],
              "banner_image" => attachment,
              "slug" => slug,
              "decidim_highlighted_scope_id" => scope&.id,
              "start_voting_date" => start_voting_date,
              "end_voting_date" => end_voting_date
            }
          }
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when banner_image is too big" do
          before do
            organization.settings.tap do |settings|
              settings.upload.maximum_file_size.default = 5
            end
            ActiveStorage::Blob.find_signed(attachment).update(byte_size: 6.megabytes)
          end

          it { is_expected.not_to be_valid }
        end

        context "when images are not the expected type" do
          let(:attachment) { Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf") }

          it { is_expected.not_to be_valid }
        end

        context "when default language in title is missing" do
          let(:title) do
            {
              ca: "Títol"
            }
          end

          it { is_expected.to be_invalid }
        end

        context "when default language in subtitle is missing" do
          let(:subtitle) do
            {
              ca: "Subtítol"
            }
          end

          it { is_expected.to be_invalid }
        end

        context "when default language in description is missing" do
          let(:description) do
            {
              ca: "Descripció"
            }
          end

          it { is_expected.to be_invalid }
        end

        context "when slug is missing" do
          let(:slug) { nil }

          it { is_expected.to be_invalid }
        end

        context "when slug is not valid" do
          let(:slug) { "123" }

          it { is_expected.to be_invalid }
        end

        context "when slug is not unique" do
          context "when in the same organization" do
            before do
              create(:consultation, slug:, organization:)
            end

            it "is not valid" do
              expect(subject).not_to be_valid
              expect(subject.errors[:slug]).not_to be_empty
            end
          end

          context "when in another organization" do
            before do
              create(:consultation, slug:)
            end

            it "is valid" do
              expect(subject).to be_valid
            end
          end
        end

        describe "start_voting_date" do
          context "when it is missing" do
            let(:start_voting_date) { nil }

            it { is_expected.to be_invalid }
          end

          context "when it is after end_voting_date" do
            let(:start_voting_date) { end_voting_date + 1.day }

            it { is_expected.to be_invalid }
          end
        end

        describe "end_voting_date" do
          context "when it is missing" do
            let(:end_voting_date) { nil }

            it { is_expected.to be_invalid }
          end

          context "when it is before start_voting_date" do
            let(:end_voting_date) { start_voting_date - 1.day }

            it { is_expected.to be_invalid }
          end
        end

        context "when highlighted scope is missing" do
          let(:scope) { nil }

          it { is_expected.to be_invalid }
        end
      end
    end
  end
end
