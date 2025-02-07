# frozen_string_literal: true

require "spec_helper"

module Decidim
  module CollaborativeTexts
    describe Document do
      subject { collaborative_text_document }

      let(:collaborative_text_document) { build(:collaborative_text_document) }
      let(:organization) { collaborative_text_document.component.organization }

      it { is_expected.to be_valid }
      it { is_expected.to act_as_paranoid }

      include_examples "has component"
      include_examples "resourceable"

      context "without a title" do
        let(:collaborative_text_document) { build(:collaborative_text_document, title: nil) }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
