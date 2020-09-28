# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryProcesses
    module Admin
      describe ParticipatoryProcessGroupForm do
        subject { described_class.from_params(attributes).with_context(current_organization: organization) }

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
        let(:attachment) { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }

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

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when hero_image is too big" do
          before do
            organization.settings.tap do |settings|
              settings.upload.maximum_file_size.default = 5
            end
            expect(subject.hero_image).to receive(:size).and_return(6.megabytes)
          end

          it { is_expected.not_to be_valid }
        end

        context "when images are not the expected type" do
          let(:attachment) { Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf") }

          it { is_expected.not_to be_valid }
        end

        context "when default language in title is missing" do
          let(:name) do
            {
              ca: "Títol"
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
      end
    end
  end
end
