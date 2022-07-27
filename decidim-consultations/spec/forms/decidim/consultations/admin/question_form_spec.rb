# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Consultations
    module Admin
      describe QuestionForm do
        subject do
          described_class
            .from_params(attributes)
            .with_context(
              current_organization: organization,
              current_consultation: consultation
            )
        end

        let(:organization) { create :organization }
        let(:consultation) { create :consultation, organization: }
        let(:scope) { create :scope, organization: }
        let(:slug) { "slug" }
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
        let(:promoter_group) do
          {
            en: "Promoter group",
            es: "Grupo promotor",
            ca: "Grup promotor"
          }
        end
        let(:participatory_scope) do
          {
            en: "Participatory scope",
            es: "Ámbito participativo",
            ca: "Àmbit participatiu"
          }
        end
        let(:what_is_decided) do
          {
            en: "What is decided",
            es: "Qué se decide",
            ca: "Què es decideix"
          }
        end
        let(:banner_image) { upload_test_file(Decidim::Dev.test_file("city.jpeg", "image/jpeg")) }
        let(:hero_image) { upload_test_file(Decidim::Dev.test_file("city.jpeg", "image/jpeg")) }
        let(:origin_scope) do
          {
            en: "",
            es: "",
            ca: ""
          }
        end
        let(:origin_title) do
          {
            en: "",
            es: "",
            ca: ""
          }
        end
        let(:origin_url) { nil }
        let(:external_voting) { false }
        let(:i_frame_url) { nil }
        let(:order) { 1 }
        let(:attributes) do
          {
            "question" => {
              "slug" => slug,
              "title_en" => title[:en],
              "title_es" => title[:es],
              "title_ca" => title[:ca],
              "subtitle_en" => subtitle[:en],
              "subtitle_es" => subtitle[:es],
              "subtitle_ca" => subtitle[:ca],
              "promoter_group_en" => promoter_group[:en],
              "promoter_group_es" => promoter_group[:es],
              "promoter_group_ca" => promoter_group[:ca],
              "participatory_scope_en" => participatory_scope[:en],
              "participatory_scope_es" => participatory_scope[:es],
              "participatory_scope_ca" => participatory_scope[:ca],
              "what_is_decided_en" => what_is_decided[:en],
              "what_is_decided_es" => what_is_decided[:es],
              "what_is_decided_ca" => what_is_decided[:ca],
              "decidim_scope_id" => scope&.id,
              "hero_image" => hero_image,
              "banner_image" => banner_image,
              "origin_scope_en" => origin_scope[:en],
              "origin_scope_es" => origin_scope[:es],
              "origin_scope_ca" => origin_scope[:ca],
              "origin_title_en" => origin_title[:en],
              "origin_title_es" => origin_title[:es],
              "origin_title_ca" => origin_title[:ca],
              "origin_url" => origin_url,
              "external_voting" => external_voting,
              "i_frame_url" => i_frame_url,
              order:
            }
          }
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when banner_image" do
          context "and it is too big" do
            before do
              organization.settings.tap do |settings|
                settings.upload.maximum_file_size.default = 5
              end
              ActiveStorage::Blob.find_signed(banner_image).update(byte_size: 6.megabytes)
            end

            it { is_expected.not_to be_valid }
          end

          context "and it hasn't the expected type" do
            let(:banner_image) { Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf") }

            it { is_expected.not_to be_valid }
          end
        end

        context "when hero_image" do
          context "and it is too big" do
            before do
              organization.settings.tap do |settings|
                settings.upload.maximum_file_size.default = 5
              end
              ActiveStorage::Blob.find_signed(hero_image).update(byte_size: 6.megabytes)
            end

            it { is_expected.not_to be_valid }
          end

          context "and it hasn't the expected type" do
            let(:hero_image) { upload_test_file(Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf")) }

            it { is_expected.not_to be_valid }
          end
        end

        context "when default language in title is missing" do
          let(:title) do
            { ca: "Títol" }
          end

          it { is_expected.to be_invalid }
        end

        context "when default language in subtitle is missing" do
          let(:subtitle) do
            { ca: "Subtítol" }
          end

          it { is_expected.to be_invalid }
        end

        context "when default language in promoter group is missing" do
          let(:promoter_group) do
            { ca: "Grup promotor" }
          end

          it { is_expected.to be_invalid }
        end

        context "when default language in participatory scope is missing" do
          let(:participatory_scope) do
            { ca: "Àmbit participatiu" }
          end

          it { is_expected.to be_invalid }
        end

        context "when default language in what is decided is missing" do
          let(:what_is_decided) do
            { ca: "Què es decideix" }
          end

          it { is_expected.to be_invalid }
        end

        context "when scope is missing" do
          let(:scope) { nil }

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
          context "when in the same consultation" do
            before do
              create(:question, slug:, consultation:)
            end

            it "is not valid" do
              expect(subject).not_to be_valid
              expect(subject.errors[:slug]).not_to be_empty
            end
          end

          context "when in another organization" do
            let(:consultation) { create :consultation }

            before do
              create(:question, slug:, consultation:)
            end

            it { is_expected.to be_valid }
          end
        end

        context "when only origin_url is defined" do
          let(:origin_url) { "https://www.aspgems.com/" }

          it { is_expected.not_to be_valid }
        end

        context "when only origin_scope is defined" do
          let(:origin_scope) do
            {
              en: "Origin scope",
              es: "Origin scope",
              ca: "Origin scope"
            }
          end

          it { is_expected.not_to be_valid }
        end

        context "when only origin_title is defined" do
          let(:origin_title) do
            {
              en: "Origin title",
              es: "Origin title",
              ca: "Origin title"
            }
          end

          it { is_expected.not_to be_valid }
        end

        context "when external_voting is enabled" do
          let(:external_voting) { true }

          context "and i_frame_url is nil" do
            let(:i_frame_url) { nil }

            it { is_expected.to be_invalid }
          end
        end

        context "when order is nil" do
          let(:order) { nil }

          it { is_expected.to be_valid }
        end
      end
    end
  end
end
