# frozen_string_literal: true

require "spec_helper"

module Decidim
  module CollaborativeTexts
    describe SuggestionPresenter, type: :helper do
      subject(:presenter) { described_class.new(suggestion) }

      let(:suggestion) { build(:collaborative_text_suggestion) }

      describe "#summary" do
        let(:changeset) { { "original" => %w(A b), "replace" => %w(a b c) } }
        let(:suggestion) { build(:collaborative_text_suggestion, changeset:) }

        it "summarizes as a replace" do
          expect(presenter.text).to eq("a b c")
          expect(presenter.original).to eq("A b")
          expect(presenter.type).to eq(:replace)
          expect(presenter.summary).to include("a b c")
          expect(presenter.summary).to include("Replace:")
          expect(presenter.summary).not_to include("Remove:")
          expect(presenter.summary).not_to include("Add:")
          expect(presenter.safe_json).to eq(
            id: suggestion.id,
            changeset: suggestion.changeset,
            summary: presenter.summary,
            status: suggestion.status,
            type: presenter.type,
            createdAt: suggestion.created_at
          )
        end

        context "when changeset is empty" do
          let(:changeset) { {} }

          it "returns an empty string" do
            expect(presenter.text).to eq("")
            expect(presenter.original).to eq("")
            expect(presenter.type).to eq(:remove)
            expect(presenter.summary).to include("Remove:")
            expect(presenter.summary).not_to include("Replace:")
            expect(presenter.summary).not_to include("Add:")
          end
        end

        context "when no original text" do
          let(:changeset) { { "replace" => %w(a b c) } }

          it "summarizes as an add" do
            expect(presenter.text).to eq("a b c")
            expect(presenter.original).to eq("")
            expect(presenter.type).to eq(:add)
            expect(presenter.summary).to include("a b c")
            expect(presenter.summary).not_to include("Remove:")
            expect(presenter.summary).not_to include("Replace:")
            expect(presenter.summary).to include("Add:")
          end
        end

        context "when no replace text" do
          let(:changeset) { { "original" => %w(A b) } }

          it "summarizes as a remove" do
            expect(presenter.text).to eq("")
            expect(presenter.original).to eq("A b")
            expect(presenter.type).to eq(:remove)
            expect(presenter.summary).to include("Remove:")
            expect(presenter.summary).not_to include("Replace:")
            expect(presenter.summary).not_to include("Add:")
          end
        end

        context "when changeset is big" do
          let(:changeset) { { "original" => ["A" * 100], "replace" => ["a" * 100, "b" * 100] } }
          let(:length) { 150 + "Replace: ".length }

          it "truncates the summary to 150 characters" do
            expect(suggestion.presenter.text.length).to be > length
            expect(strip_tags(suggestion.presenter.summary).length).to be <= length
          end

          context "when changeset has html" do
            let(:changeset) do
              { "replace" => ["<script>alert('xss')</script>"] }
            end

            it "sanitizes the summary" do
              expect(suggestion.presenter.text).not_to include("<script>")
            end
          end
        end
      end
    end
  end
end
