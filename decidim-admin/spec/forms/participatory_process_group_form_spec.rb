# coding: utf-8
# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Admin
    describe ParticipatoryProcessGroupForm do
      let(:organization) { create :organization }
      let(:participatory_processes) { create_list :participatory_process, 3, organization: organization }
      let(:name) do
        {
          en: "Title",
          es: "Título",
          ca: "Títol"
        }
      end
      let(:description) do
        {
          en: "Description",
          es: "Descripción",
          ca: "Descripció"
        }
      end
      let(:attachment) { test_file("city.jpeg", "image/jpeg") }

      let(:attributes) do
        {
          "name_en" => name[:en],
          "name_es" => name[:es],
          "name_ca" => name[:ca],
          "description_en" => description[:en],
          "description_es" => description[:es],
          "description_ca" => description[:ca],
          "hero_image" => attachment,
          "participatory_processes" => participatory_processes
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
          allow(Decidim).to receive(:maximum_attachment_size).and_return(5.megabytes)
          expect(subject.hero_image).to receive(:size).and_return(6.megabytes)
        end

        it { is_expected.not_to be_valid }
      end

      context "when images are not the expected type" do
        let(:attachment) { test_file("Exampledocument.pdf", "application/pdf") }

        it { is_expected.not_to be_valid }
      end

      context "when some language in title is missing" do
        let(:name) do
          {
            en: "Title",
            ca: "Títol"
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
    end
  end
end
