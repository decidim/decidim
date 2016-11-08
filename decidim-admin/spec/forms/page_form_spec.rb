# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Admin
    describe PageForm do
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
          "page" => {
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

      subject { described_class.from_params(attributes) }

      context "when everything is OK" do
        it { is_expected.to be_valid }
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

      context "when some language in content is missing" do
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

      context "when organization is missing" do
        let(:organization) { nil }

        it { is_expected.to be_invalid }
      end

      context "when slug is not unique" do
        before do
          create(:page, organization: organization, slug: slug)
        end

        it "is not valid" do
          expect(subject).to_not be_valid
          expect(subject.errors[:slug]).to_not be_empty
        end
      end

      context "when the slug exists in another organization" do
        before do
          create(:page, slug: slug)
        end

        it { is_expected.to be_valid }
      end
    end
  end
end
