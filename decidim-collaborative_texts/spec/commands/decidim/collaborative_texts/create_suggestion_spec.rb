# frozen_string_literal: true

require "spec_helper"

module Decidim
  module CollaborativeTexts
    describe CreateSuggestion do
      subject { described_class.new(form) }

      let!(:document) { create(:collaborative_text_document, :with_body) }
      let(:organization) { document.component.organization }
      let(:user) { create(:user, :confirmed, organization:) }
      let(:document_version) { document.current_version }
      let(:changeset) do
        {
          "firstNode" => "1",
          "lastNode" => "2",
          "original" => ["Original line"],
          "replace" => ["Replacement line"]
        }
      end
      let(:form) do
        double(
          invalid?: invalid,
          author: user,
          document_version:,
          changeset:,
          document:,
          current_user: user,
          current_organization: organization,
          current_component: document.component
        )
      end
      let(:invalid) { false }

      context "when the form is not valid" do
        let(:invalid) { true }

        it "is not valid" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end

      context "when everything is ok" do
        let(:suggestion) { Decidim::CollaborativeTexts::Suggestion.last }

        it "creates a new suggestion" do
          expect { subject.call }.to change(Decidim::CollaborativeTexts::Suggestion, :count).by(1)
          expect(suggestion.document_version).to eq document_version
          expect(suggestion.changeset).to eq changeset
          expect(suggestion.author).to eq user
        end

        it "traces the action", versioning: true do
          expect(Decidim.traceability)
            .to receive(:create!)
            .with(
              Decidim::CollaborativeTexts::Suggestion,
              user,
              {
                author: user,
                changeset:,
                document_version:
              },
              hash_including(extra: hash_including(:participatory_space, :resource))
            )
            .and_call_original

          subject.call
        end
      end

      context "when the document belongs to the organization the user is acting in" do
        it "locks the document through the current component and the version through the document" do
          queries = capture_queries { subject.call }

          document_lock = queries.find { |sql| sql.include?("FOR UPDATE") && sql.include?("decidim_collaborative_texts_documents") }
          version_lock = queries.find { |sql| sql.include?("FOR UPDATE") && sql.include?("decidim_collaborative_texts_versions") }

          expect(document_lock).to include("decidim_component_id")
          expect(version_lock).to include("document_id")
        end
      end

      context "when the document belongs to another organization" do
        let(:other_organization) { create(:organization) }
        let(:other_component) { create(:collaborative_text_component, organization: other_organization) }
        let(:other_document) { create(:collaborative_text_document, :with_body, component: other_component) }

        let(:form) do
          double(
            invalid?: false,
            author: user,
            document_version: other_document.current_version,
            changeset:,
            document: other_document,
            current_user: user,
            current_organization: organization,
            current_component: document.component
          )
        end

        it "does not lock a document from another organization" do
          expect { subject.call }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      def capture_queries
        queries = []
        subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") { |_, _, _, _, data| queries << data[:sql] }
        yield
        queries
      ensure
        ActiveSupport::Notifications.unsubscribe(subscriber)
      end
    end
  end
end
