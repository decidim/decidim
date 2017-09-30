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
    end
  end
end
