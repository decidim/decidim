# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe StaticPageForm do
      subject { described_class.from_params(attributes).with_context(current_organization: organization) }

      let(:title) do
        {
          en: "Title",
          es: "Título",
          ca: "Títol"
        }
      end
      let(:content) do
        {
          en: "content",
          es: "Descripción",
          ca: "Descripció"
        }
      end
      let(:slug) { "slug" }
      let(:organization) { create(:organization) }
      let(:attributes) do
        {
          "static_page" => {
            "title_en" => title[:en],
            "title_es" => title[:es],
            "title_ca" => title[:ca],
            "content_en" => content[:en],
            "content_es" => content[:es],
            "content_ca" => content[:ca],
            "organization" => organization,
            "slug" => slug
          }
        }
      end

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when default language in title is missing" do
        let(:title) do
          {
            es: "Título",
            ca: "Títol"
          }
        end

        it { is_expected.to be_invalid }
      end

      context "when default language in content is missing" do
        let(:content) do
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

      context "when slug is invalid" do
        let(:slug) { "#Slug.Invalid!" }

        it { is_expected.to be_invalid }
      end

      context "when slug is not downcase" do
        let(:slug) { "SLUG" }

        it { is_expected.to be_valid }
      end

      context "when slug is not unique" do
        before do
          create(:static_page, organization: organization, slug: slug)
        end

        it "is not valid" do
          expect(subject).not_to be_valid
          expect(subject.errors[:slug]).not_to be_empty
        end
      end

      context "when the slug exists in another organization" do
        before do
          create(:static_page, slug: slug)
        end

        it { is_expected.to be_valid }
      end

      context "when slug is a full URL" do
        let(:slug) { "http://example.org" }

        it { is_expected.not_to be_valid }
      end

      context "when slug is a valid path" do
        let(:slug) { "my/slug/" }

        it { is_expected.to be_valid }
      end

      context "when slug is a valid path with underscore" do
        let(:slug) { "my/super_slug/" }

        it { is_expected.to be_valid }
      end

      context "when organization requires authentication" do
        let(:organization) { create(:organization, force_users_to_authenticate_before_access_organization: true) }
        let(:attributes) do
          {
            "static_page" => {
              "title_en" => title[:en],
              "title_es" => title[:es],
              "title_ca" => title[:ca],
              "content_en" => content[:en],
              "content_es" => content[:es],
              "content_ca" => content[:ca],
              "organization" => organization,
              "slug" => slug,
              "allow_public_access" => allow_public_access
            }
          }
        end

        context "with allowed public access" do
          let(:allow_public_access) { true }

          it { is_expected.to be_valid }
        end

        context "with not allowed public access" do
          let(:allow_public_access) { false }

          it { is_expected.to be_valid }
        end
      end

      describe "#control_public_access?" do
        context "when organization does not require authentication" do
          it "returns false" do
            expect(subject.control_public_access?).to be(false)
          end
        end

        context "when organization requires authentication" do
          let(:organization) { create(:organization, force_users_to_authenticate_before_access_organization: true) }

          it "returns true" do
            expect(subject.control_public_access?).to be(true)
          end
        end
      end
    end
  end
end
