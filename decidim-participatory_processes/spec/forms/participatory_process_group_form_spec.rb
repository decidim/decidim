# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryProcesses
    module Admin
      describe ParticipatoryProcessGroupForm do
        subject { described_class.from_params(attributes).with_context(current_organization: organization) }

        let(:organization) { create :organization }
        let(:participatory_processes) { create_list :participatory_process, 3, organization: organization }
        let(:title) do
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
        let(:meta_attributes) do
          %w(
          developer_group
          local_area
          meta_scope
          target
          participatory_scope
          participatory_structure
          ).inject({}) do |attrs, attr|
            [:en, :es, :ca].each do |locale|
              attrs.update("#{attr}_#{locale}" => "#{attr.titleize} #{locale}")
            end
            attrs
          end
        end
        let(:hashtag) { "hashtag" }
        let(:group_url) { "http://example.org" }
        let(:attachment) { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }

        let(:attributes) do
          {
            "title_en" => title[:en],
            "title_es" => title[:es],
            "title_ca" => title[:ca],
            "description_en" => description[:en],
            "description_es" => description[:es],
            "description_ca" => description[:ca],
            "hashtag" => hashtag,
            "group_url" => group_url,
            "hero_image" => attachment,
            "participatory_processes" => participatory_processes
          }.merge(meta_attributes)
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
          let(:title) do
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

        context "when group_url doesn't start with http" do
          let(:group_url) { "example.org" }

          it "adds it" do
            expect(subject.group_url).to eq("http://example.org")
          end
        end

        context "when it's not a valid URL" do
          let(:group_url) { "Groundhog Day" }

          it { is_expected.to be_invalid }
        end
      end
    end
  end
end
