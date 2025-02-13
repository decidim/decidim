# frozen_string_literal: true

require "spec_helper"

module Decidim
  module CollaborativeTexts
    describe Document do
      subject { document }

      let(:document) { build(:collaborative_text_document) }
      let(:organization) { document.component.organization }

      it { is_expected.to be_valid }
      it { is_expected.to act_as_paranoid }

      include_examples "has component"
      include_examples "resourceable"

      context "without a title" do
        let(:document) { build(:collaborative_text_document, title: nil) }

        it { is_expected.not_to be_valid }
      end

      it "has a versions" do
        expect(document.versions).to all(be_a(Decidim::CollaborativeTexts::Version))
      end

      it "current version points to last created" do
        document.save!
        version = create(:collaborative_text_version, created_at: 1.second.from_now, document: document)
        expect(document.reload.versions.count).to eq(4)
        expect(document.current_version).to eq(version)
      end
    end
  end
end
