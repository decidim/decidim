# coding: utf-8
# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Admin
    describe ParticipatoryProcessForm do
      let(:organization) { create :organization }
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
      let(:short_description) do
        {
          en: "Short description",
          es: "Descripción corta",
          ca: "Descripció curta"
        }
      end
      let(:slug) { "slug" }
      let(:attachement) { test_file("city.jpeg", "image/jpeg") }
      let(:attributes) do
        {
          "participatory_process" => {
            "title_en" => title[:en],
            "title_es" => title[:es],
            "title_ca" => title[:ca],
            "subtitle_en" => subtitle[:en],
            "subtitle_es" => subtitle[:es],
            "subtitle_ca" => subtitle[:ca],
            "description_en" => description[:en],
            "description_es" => description[:es],
            "description_ca" => description[:ca],
            "short_description_en" => short_description[:en],
            "short_description_es" => short_description[:es],
            "short_description_ca" => short_description[:ca],
            "hero_image" => attachement,
            "banner_image" => attachement,
            "slug" => slug
          }
        }
      end
      before do
        Decidim::AttachmentUploader.enable_processing = true
      end

      subject { described_class.from_params(attributes).with_context(current_organization: organization) }

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when hero_image is too big" do
        before do
          an_amount_too_large = (Decidim.maximum_attachment_size + 1).megabytes
          expect(subject.hero_image).to receive(:size).twice.and_return(an_amount_too_large)
        end

        it { is_expected.not_to be_valid }
      end

      context "when banner_image is too big" do
        before do
          an_amount_too_large = (Decidim.maximum_attachment_size + 1).megabytes
          expect(subject.banner_image).to receive(:size).twice.and_return(an_amount_too_large)
        end

        it { is_expected.not_to be_valid }
      end

      context "when images are not the expected type" do
        let(:attachement) { test_file("Exampledocument.pdf", "application/pdf") }

        it { is_expected.not_to be_valid }
      end

      context "when some language in title is missing" do
        let(:title) do
          {
            en: "Title",
            ca: "Títol"
          }
        end

        it { is_expected.to be_invalid }
      end

      context "when some language in subtitle is missing" do
        let(:subtitle) do
          {
            en: "Subtitle",
            ca: "Subtítol"
          }
        end

        it { is_expected.to be_invalid }
      end

      context "when some language in description is missing" do
        let(:description) do
          {
            ca: "Descripció"
          }
        end

        it { is_expected.to be_invalid }
      end

      context "when some language in short_description is missing" do
        let(:short_description) do
          {
            en: "Short description"
          }
        end

        it { is_expected.to be_invalid }
      end

      context "when slug is missing" do
        let(:slug) { nil }

        it { is_expected.to be_invalid }
      end

      context "when slug is not unique" do
        context "in the same organization" do
          before do
            create(:participatory_process, slug: slug, organization: organization)
          end

          it "is not valid" do
            expect(subject).not_to be_valid
            expect(subject.errors[:slug]).not_to be_empty
          end
        end

        context "in another organization" do
          before do
            create(:participatory_process, slug: slug)
          end

          it "is valid" do
            expect(subject).to be_valid
          end
        end
      end
    end
  end
end
