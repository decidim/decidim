# frozen_string_literal: true

require "spec_helper"

module Decidim
  module CollaborativeTexts
    describe RolloutForm do
      subject(:form) { described_class.from_params(attributes).with_context(context) }

      let!(:suggestions) { create_list(:collaborative_text_suggestion, 3, document_version:) }
      let(:document) { document_version.document }
      let(:document_version) { create(:collaborative_text_version) }
      let(:context) do
        {
          document:
        }
      end
      let(:attributes) do
        {
          draft:,
          body:,
          accepted:,
          pending:
        }
      end
      let(:draft) { false }
      let(:body) { "This is the body" }
      let(:accepted) { [suggestions.first.id] }
      let(:pending) { [suggestions.second.id, suggestions.last.id] }

      describe "#document" do
        it "returns the document" do
          expect(form.document).to eq(document)
          expect(form.document.suggestions).to include(*suggestions)
        end

        it "returns the pending suggestions" do
          expect(form.pending_suggestions).to eq([suggestions.second, suggestions.last])
        end

        it "returns the accepted suggestions" do
          expect(form.accepted_suggestions).to eq([suggestions.first])
        end
      end

      describe "validations" do
        it { is_expected.to be_valid }

        describe "when body is missing" do
          let(:body) { nil }

          it { is_expected.not_to be_valid }
        end

        describe "when body is empty" do
          let(:body) { "" }

          it { is_expected.not_to be_valid }
        end
      end
    end
  end
end
