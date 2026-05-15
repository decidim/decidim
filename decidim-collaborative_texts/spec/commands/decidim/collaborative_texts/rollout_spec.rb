# frozen_string_literal: true

require "spec_helper"

module Decidim
  module CollaborativeTexts
    describe Rollout do
      subject { described_class.new(form) }

      let!(:document) { create(:collaborative_text_document, :with_body) }
      let(:document_version) { document.current_version }
      let(:organization) { document.component.organization }
      let(:user) { create(:user, :confirmed, organization:) }
      let!(:accepted_suggestion) { create(:collaborative_text_suggestion, :pending, document_version:) }
      let!(:pending_suggestion) { create(:collaborative_text_suggestion, :pending, document_version:) }
      let(:form) do
        double(
          invalid?: invalid,
          body:,
          document:,
          draft:,
          draft?: draft,
          current_user: user,
          current_organization: organization,
          accepted_suggestions: document.suggestions.where(id: accepted_suggestion.id),
          pending_suggestions: document.suggestions.where(id: pending_suggestion.id)
        )
      end
      let(:draft) { false }
      let(:body) { ::Faker::HTML.paragraph }
      let(:invalid) { false }

      context "when the form is not valid" do
        let(:invalid) { true }

        it "is not valid" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end

      shared_examples "a valid form" do
        it "is valid" do
          expect { subject.call }.to broadcast(:ok)
        end

        it "adds the accepted suggestion authors as co-authors" do
          expect { subject.call }.to change { document.authors.count }.by(1)
          expect(document.authors).to include(accepted_suggestion.author)
          expect(document.authors).not_to include(pending_suggestion.author)
        end

        it "publishes the event" do
          expect(Decidim::EventsManager).to receive(:publish).with(
            event: "decidim.events.collaborative_texts.suggestion_accepted",
            event_class: Decidim::CollaborativeTexts::SuggestionAcceptedEvent,
            resource: document,
            affected_users: [accepted_suggestion.author]
          )

          subject.call
        end
      end

      context "when everything is ok" do
        let(:draft) { false }

        it_behaves_like "a valid form"

        it "creates a new version and updates accepted" do
          expect(document.suggestions.accepted.count).to eq(0)
          expect(document.suggestions.pending.count).to eq(2)
          expect { subject.call }.to change { document.document_versions.count }.by(1)

          expect(document.suggestions.accepted.count).to eq(1)
          expect(document.suggestions.pending.count).to eq(1)
          expect(document.document_versions.last.draft).to be(false)
          expect(accepted_suggestion.reload.document_version).not_to eq(pending_suggestion.reload.document_version)
          expect(accepted_suggestion.document_version).to eq(document.document_versions.first)
          expect(pending_suggestion.document_version).to eq(document.document_versions.last)
        end

        context "when the form is a draft" do
          let(:draft) { true }

          it_behaves_like "a valid form"

          it "creates a new version and updates accepted" do
            expect(document.suggestions.accepted.count).to eq(0)
            expect(document.suggestions.pending.count).to eq(2)
            expect { subject.call }.to change { document.document_versions.count }.by(1)
            expect(document.suggestions.accepted.count).to eq(1)
            expect(document.suggestions.pending.count).to eq(1)
            expect(document.document_versions.last.draft).to be(true)
            expect(accepted_suggestion.reload.document_version).to eq(pending_suggestion.reload.document_version)
            expect(accepted_suggestion.document_version).to eq(document.document_versions.first)
          end
        end
      end
    end
  end
end
