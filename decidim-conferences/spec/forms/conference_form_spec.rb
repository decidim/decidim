# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Conferences
    module Admin
      describe ConferenceForm do
        subject { described_class.from_params(attributes).with_context(current_organization: organization) }

        let(:organization) { create :organization }
        let(:title) do
          {
            en: "Title",
            es: "Título",
            ca: "Títol"
          }
        end
        let(:slogan) do
          {
            en: "Slogan",
            es: "Eslogan",
            ca: "Eslògan"
          }
        end
        let(:description) do
          {
            en: "Description",
            es: "Descripción",
            ca: "Descripció"
          }
        end
        let(:short_description) do
          {
            en: "Short description",
            es: "Descripción corta",
            ca: "Descripció curta"
          }
        end
        let(:slug) { "slug" }
        let(:attachment) { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }
        let(:show_statistics) { true }
        let(:objectives) do
          {
            en: "Objectives",
            es: "Objetivos",
            ca: "Objectius"
          }
        end
        let(:start_date) { 2.days.from_now }
        let(:end_date) { 5.days.from_now }
        let(:attributes) do
          {
            "conference" => {
              "title_en" => title[:en],
              "title_es" => title[:es],
              "title_ca" => title[:ca],
              "slogan_en" => slogan[:en],
              "slogan_es" => slogan[:es],
              "slogan_ca" => slogan[:ca],
              "description_en" => description[:en],
              "description_es" => description[:es],
              "description_ca" => description[:ca],
              "short_description_en" => short_description[:en],
              "short_description_es" => short_description[:es],
              "short_description_ca" => short_description[:ca],
              "hero_image" => attachment,
              "banner_image" => attachment,
              "slug" => slug,
              "show_statistics" => show_statistics,
              "objectives_en" => objectives[:en],
              "objectives_es" => objectives[:es],
              "objectives_ca" => objectives[:ca],
              "start_date" => start_date,
              "end_date" => end_date
            }
          }
        end

        before do
          Decidim::AttachmentUploader.enable_processing = true
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when hero_image is too big" do
          before do
            allow(Decidim).to receive(:maximum_attachment_size).and_return(5.megabytes)
            expect(subject.hero_image).to receive(:size).twice.and_return(6.megabytes)
          end

          it { is_expected.not_to be_valid }
        end

        context "when banner_image is too big" do
          before do
            allow(Decidim).to receive(:maximum_attachment_size).and_return(5.megabytes)
            expect(subject.banner_image).to receive(:size).twice.and_return(6.megabytes)
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

        context "when default language in slogan is missing" do
          let(:slogan) do
            {
              ca: "Slogan"
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

        context "when default language in short_description is missing" do
          let(:short_description) do
            {
              ca: "Descripció curta"
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
              create(:conference, slug: slug, organization: organization)
            end

            it "is not valid" do
              expect(subject).not_to be_valid
              expect(subject.errors[:slug]).not_to be_empty
            end
          end

          context "when in another organization" do
            before do
              create(:conference, slug: slug)
            end

            it "is valid" do
              expect(subject).to be_valid
            end
          end
        end
      end
    end
  end
end
