# frozen_string_literal: true

require "spec_helper"

module Decidim
  module CollaborativeTexts
    describe Version do
      subject { collaborative_text_version }

      let(:collaborative_text_version) { build(:collaborative_text_version, draft:) }
      let(:draft) { false }

      it { is_expected.to be_valid }
      it { is_expected.not_to be_draft }

      it "returns the version number" do
        expect(collaborative_text_version.version_number).to eq(0)
      end

      it "has a document" do
        expect(collaborative_text_version.document).to be_a(Decidim::CollaborativeTexts::Document)
      end

      it "is invalid without a body" do
        collaborative_text_version.body = nil
        expect(collaborative_text_version).to be_invalid
      end

      it "is invalid without a document" do
        collaborative_text_version.document = nil
        expect(collaborative_text_version).to be_invalid
      end

      context "when it is a draft" do
        let(:draft) { true }

        it { is_expected.to be_valid }
        it { is_expected.to be_draft }
      end

      context "when version already exists" do
        let!(:previous_version) { create(:collaborative_text_version, document: collaborative_text_version.document, draft: previous_draft) }
        let(:previous_draft) { false }

        it { is_expected.to be_valid }
        it { is_expected.not_to be_draft }

        it "returns the version number" do
          expect(collaborative_text_version.version_number).to eq(1)
        end

        context "when previous version is a draft" do
          let(:previous_draft) { true }

          it { is_expected.to be_valid }
        end

        context "when it is a draft" do
          let(:draft) { true }

          it { is_expected.to be_valid }
          it { is_expected.to be_draft }

          context "when previous version is a draft" do
            let(:previous_draft) { true }

            it { is_expected.to be_invalid }
          end
        end
      end
    end
  end
end
