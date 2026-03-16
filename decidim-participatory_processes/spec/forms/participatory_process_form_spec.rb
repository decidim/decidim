# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryProcesses
    module Admin
      describe ParticipatoryProcessForm do
        subject { described_class.from_params(attributes).with_context(current_organization: organization) }

        let(:organization) { create(:organization) }
        let(:root_taxonomy) { create(:taxonomy, organization:) }
        let!(:taxonomies) { create_list(:taxonomy, 3, parent: root_taxonomy, organization:) }
        let!(:taxonomy_filter1) { create(:taxonomy_filter, participatory_space_manifests: ["participatory_processes"], root_taxonomy:) }
        let!(:taxonomy_filter2) { create(:taxonomy_filter, participatory_space_manifests: ["participatory_processes"], root_taxonomy:) }
        let!(:taxonomy_filter3) { create(:taxonomy_filter, participatory_space_manifests: ["assemblies"], root_taxonomy:) }
        let!(:taxonomy_filter4) { create(:taxonomy_filter, participatory_space_manifests: ["participatory_processes"]) }
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
        let(:weight) { 1 }
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
        let(:start_date) { 1.month.ago }
        let(:end_date) { 1.month.from_now }
        let(:slug) { "slug" }
        let(:attachment) { upload_test_file(Decidim::Dev.test_file("city.jpeg", "image/jpeg")) }
        let(:private_space) { true }
        let(:has_members) { true }
        let(:access_mode) { "open" }
        let(:attributes) do
          {
            "participatory_process" => {
              "title_en" => title[:en],
              "title_es" => title[:es],
              "title_ca" => title[:ca],
              "subtitle_en" => subtitle[:en],
              "subtitle_es" => subtitle[:es],
              "subtitle_ca" => subtitle[:ca],
              "weight" => weight,
              "description_en" => description[:en],
              "description_es" => description[:es],
              "description_ca" => description[:ca],
              "short_description_en" => short_description[:en],
              "short_description_es" => short_description[:es],
              "short_description_ca" => short_description[:ca],
              "start_date" => start_date,
              "end_date" => end_date,
              "hero_image" => attachment,
              "slug" => slug,
              "private_space" => private_space,
              "has_members" => has_members,
              "access_mode" => access_mode,
              "taxonomies" => [taxonomies.first.id, taxonomies.second.id]
            }
          }
        end

        context "when has_members is true" do
          let(:has_members) { true }

          it { is_expected.to be_valid }
        end

        context "when has_members is false" do
          let(:has_members) { false }

          it { is_expected.to be_valid }
        end

        context "when access_mode is missing" do
          let(:access_mode) { nil }

          it { is_expected.to be_invalid }
        end

        context "when access_mode is present" do
          let(:access_mode) { "open" }

          it { is_expected.to be_valid }
        end

        context "when access_mode is invalid" do
          let(:access_mode) { "foo" }

          it { is_expected.to be_invalid }
        end

        describe "default access_mode" do
          let(:attributes) do
            {
              "participatory_process" => {
                "title_en" => title[:en],
                "title_es" => title[:es],
                "title_ca" => title[:ca],
                "slug" => slug,
                "weight" => weight
              }
            }
          end

          it "is :open" do
            expect(subject.access_mode).to eq("open")
          end
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        it "returns taxonomizations and taxonomies" do
          expect(subject.taxonomizations.map(&:taxonomy_id)).to eq([taxonomies.first.id, taxonomies.second.id])
          expect(subject.root_taxonomies).to eq([root_taxonomy])
          expect(subject.taxonomy_filters).to contain_exactly(taxonomy_filter1, taxonomy_filter2)
        end

        context "when taxonomies belong to another organization" do
          let!(:taxonomies) { create_list(:taxonomy, 3) }

          it { is_expected.not_to be_valid }
        end

        context "when hero_image is too big" do
          before do
            organization.settings.tap do |settings|
              settings.upload.maximum_file_size.default = 5
            end
            ActiveStorage::Blob.find_signed(attachment).update(byte_size: 6.megabytes)
          end

          it { is_expected.not_to be_valid }
        end

        context "when images are not the expected type" do
          let(:attachment) { upload_test_file(Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf")) }

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
          context "and process in the same organization" do
            before do
              create(:participatory_process, slug:, organization:)
            end

            it "is not valid" do
              expect(subject).not_to be_valid
              expect(subject.errors[:slug]).not_to be_empty
            end
          end

          context "and process in another organization" do
            before do
              create(:participatory_process, slug:)
            end

            it "is valid" do
              expect(subject).to be_valid
            end
          end
        end

        context "when the start_date is later than end_date" do
          let(:start_date) { 1.month.from_now }
          let(:end_date) { 2.months.ago }

          it { is_expected.to be_invalid }

          it "has an error" do
            subject.valid?

            expect(subject.errors).not_to be_empty
            expect(subject.errors[:end_date]).not_to be_empty
            expect(subject.errors[:start_date]).not_to be_empty
          end
        end

        context "when start_date is present" do
          let(:start_date) { 3.months.ago }

          it { is_expected.to be_valid }
        end

        context "when end_date is present" do
          let(:end_date) { 2.months.from_now }

          it { is_expected.to be_valid }
        end

        context "when start_date is not present" do
          let(:start_date) { nil }

          it { is_expected.to be_valid }
        end

        context "when end_date is not present" do
          let(:end_date) { nil }

          it { is_expected.to be_valid }
        end
      end
    end
  end
end
