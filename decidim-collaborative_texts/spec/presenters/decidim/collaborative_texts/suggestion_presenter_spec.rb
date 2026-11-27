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
            applicable: true,
            error: nil,
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

      describe "#safe_json" do
        let(:changeset) do
          {
            "original" => ["<p>Hello</p><script>alert('xss')</script>"],
            "replace" => ["<p onmouseover=\"alert('xss')\">Hello</p><img src=\"x\" onerror=\"alert('xss')\">"]
          }
        end
        let(:suggestion) { build(:collaborative_text_suggestion, changeset:) }

        it "sanitizes the changeset HTML before sending it to the client" do
          json = presenter.safe_json
          sanitized_original = json[:changeset]["original"].join
          sanitized_replace = json[:changeset]["replace"].join

          expect(sanitized_original).not_to include("<script")
          expect(sanitized_replace).not_to include("onmouseover")
          expect(sanitized_replace).not_to include("onerror")
          expect(sanitized_replace).to include("Hello")
        end

        it "sanitizes each node only once" do
          allow(presenter).to receive(:decidim_sanitize).and_call_original

          presenter.safe_json

          expect(presenter).to have_received(:decidim_sanitize).twice
        end

        context "when a legacy changeset leaves less than the default omission size" do
          let(:changeset) do
            { "original" => ["a" * (Suggestion::MAX_CHANGESET_BYTES - remaining), "bb"] }
          end

          context "with one byte remaining" do
            let(:remaining) { 1 }

            it "truncates the node without raising" do
              sanitized = presenter.safe_json[:changeset]["original"]

              expect(sanitized).to eq(["a" * (Suggestion::MAX_CHANGESET_BYTES - 1), "b"])
              expect(sanitized.join.bytesize).to be <= Suggestion::MAX_CHANGESET_BYTES
            end
          end

          context "with two bytes remaining" do
            let(:remaining) { 2 }

            it "keeps the node unchanged" do
              sanitized = presenter.safe_json[:changeset]["original"]

              expect(sanitized).to eq(["a" * (Suggestion::MAX_CHANGESET_BYTES - 2), "bb"])
              expect(sanitized.join.bytesize).to be <= Suggestion::MAX_CHANGESET_BYTES
            end
          end
        end

        context "when the changeset is within the limits" do
          let(:changeset) { { "original" => ["ab"], "replace" => ["cd"] } }

          it "keeps the strings unchanged" do
            expect(presenter.safe_json[:changeset]).to eq(changeset)
          end

          it "is applicable" do
            json = presenter.safe_json

            expect(json[:applicable]).to be(true)
            expect(json[:error]).to be_nil
          end
        end

        context "when a legacy changeset exceeds the node limit" do
          let(:changeset) do
            {
              "original" => Array.new(Suggestion::MAX_CHANGESET_NODES + 10, "a"),
              "replace" => ["b"]
            }
          end

          it "bounds the sanitized output and marks the suggestion as not applicable" do
            json = presenter.safe_json

            expect(json[:changeset]["original"].length).to be <= Suggestion::MAX_CHANGESET_NODES
            expect(json[:changeset]["original"].join.bytesize).to be <= Suggestion::MAX_CHANGESET_BYTES
            expect(json[:applicable]).to be(false)
            expect(json[:error]).to eq(I18n.t("decidim.collaborative_texts.suggestion.not_applicable"))
          end
        end

        context "when a legacy changeset exceeds the bytes limit" do
          let(:changeset) do
            {
              "original" => ["a"],
              "replace" => ["b" * (Suggestion::MAX_CHANGESET_BYTES + 1)]
            }
          end

          it "bounds the sanitized output and marks the suggestion as not applicable" do
            json = presenter.safe_json

            expect(json[:changeset]["replace"].join.bytesize).to be <= Suggestion::MAX_CHANGESET_BYTES
            expect(json[:applicable]).to be(false)
            expect(json[:error]).to eq(I18n.t("decidim.collaborative_texts.suggestion.not_applicable"))
          end
        end
      end
    end
  end
end
