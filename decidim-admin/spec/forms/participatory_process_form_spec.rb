# coding: utf-8
# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Admin
    describe ParticipatoryProcessForm do
      let(:title) do
        {
          dev: "Title"
        }
      end

      let(:subtitle) do
        {
          dev: "Subtitle"
        }
      end

      let(:description) do
        {
          dev: "Description"
        }
      end

      let(:short_description) do
        {
          dev: "Short description"
        }
      end

      let(:slug) { "slug" }

      let(:attributes) do
        {
          "participatory_process" => {
            "title_dev" => title[:dev],
            "subtitle_dev" => subtitle[:dev],
            "description_dev" => description[:dev],
            "short_description_dev" => short_description[:dev],
            "slug" => slug
          }
        }
      end

      subject { described_class.from_params(attributes) }

      context "when everything is OK" do
        before do
          subject.valid?
        end
        it { is_expected.to be_valid }
      end

      context "when some language in title is missing" do
        let(:title) do
          {
            en: "Title"
          }
        end

        it { is_expected.to be_invalid }
      end

      context "when some language in subtitle is missing" do
        let(:subtitle) do
          {
            en: "Subtitle"
          }
        end

        it { is_expected.to be_invalid }
      end

      context "when some language in description is missing" do
        let(:description) do
          {
            en: "Descripció"
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
        before do
          create(:participatory_process, slug: slug)
        end

        it "is not valid" do
          expect(subject).to_not be_valid
          expect(subject.errors[:slug]).to_not be_empty
        end
      end
    end
  end
end
