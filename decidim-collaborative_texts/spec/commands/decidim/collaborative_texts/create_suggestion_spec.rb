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
          current_organization: organization
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
    end
  end
end
