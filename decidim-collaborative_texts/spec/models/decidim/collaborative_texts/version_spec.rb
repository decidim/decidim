# frozen_string_literal: true

require "spec_helper"

module Decidim
  module CollaborativeTexts
    describe Version do
      subject { collaborative_text_version }

      let(:collaborative_text_version) { build(:collaborative_text_version) }

      it { is_expected.to be_valid }

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
    end
  end
end
