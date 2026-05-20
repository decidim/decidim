# frozen_string_literal: true

require "spec_helper"

module Decidim
  module CollaborativeTexts
    describe SuggestionSerializer do
      subject { described_class.new(suggestion) }

      let(:suggestion) { create(:collaborative_text_suggestion) }
      let(:serialized) { subject.serialize }

      describe "#serialize" do
        it "serializes the id" do
          expect(serialized).to include(id: suggestion.id)
        end

        it "serializes the document id" do
          expect(serialized).to include(document_id: suggestion.document.id)
        end

        it "serializes the status" do
          expect(serialized).to include(status: suggestion.status)
        end

        it "serializes the original text" do
          expect(serialized[:original_text]).to eq(
            suggestion.changeset["original"]&.join(" ")&.strip
          )
        end

        it "serializes the replacement text" do
          expect(serialized[:replacement_text]).to eq(
            suggestion.changeset["replace"]&.join(" ")&.strip
          )
        end

        describe "author" do
          let(:component) { create(:collaborative_text_component) }
          let(:document) { create(:collaborative_text_document, component:) }
          let(:version) { create(:collaborative_text_version, document:) }
          let(:author) { create(:user, :confirmed, name: "Jane Doe", organization: component.organization) }
          let(:suggestion) { create(:collaborative_text_suggestion, document_version: version, author:) }

          it "serializes the author name" do
            expect(serialized[:author]).to include(name: "Jane Doe")
          end

          it "serializes the author id" do
            expect(serialized[:author]).to include(id: author.id)
          end

          it "serializes the author profile url" do
            expect(serialized[:author]).to include(url: profile_url(author.nickname))
          end
        end

        it "serializes created_at" do
          expect(serialized).to include(created_at: suggestion.created_at)
        end

        it "serializes updated_at" do
          expect(serialized).to include(updated_at: suggestion.updated_at)
        end

        def profile_url(nickname)
          Decidim::Core::Engine.routes.url_helpers.profile_url(nickname, host:, port: Capybara.server_port)
        end

        def host
          suggestion.organization.host
        end
      end
    end
  end
end
