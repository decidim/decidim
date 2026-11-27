# frozen_string_literal: true

require "spec_helper"

module Decidim
  module CollaborativeTexts
    describe Suggestion do
      subject { collaborative_text_suggestion }

      let(:document_version) { create(:collaborative_text_version) }
      let(:collaborative_text_suggestion) { build(:collaborative_text_suggestion, document_version:) }

      it { is_expected.to be_valid }

      it "has a document version" do
        expect(collaborative_text_suggestion.document_version).to be_a(Decidim::CollaborativeTexts::Version)
      end

      context "when suggestion is saved" do
        let(:another_document_version) { create(:collaborative_text_version, document: document_version.document) }
        let!(:another_collaborative_text_suggestion) { create(:collaborative_text_suggestion, document_version: another_document_version) }

        it "updates suggestions count" do
          expect(collaborative_text_suggestion.document.suggestions_count).to eq(1)
          expect(document_version.suggestions_count).to eq(0)
          collaborative_text_suggestion.save
          expect(document_version.suggestions_count).to eq(1)
          expect(collaborative_text_suggestion.document.suggestions_count).to eq(2)
        end
      end

      describe "#commentable?" do
        subject { collaborative_text_suggestion.commentable? }

        context "when the document is published" do
          let(:document) { create(:collaborative_text_document, :published) }
          let(:document_version) { create(:collaborative_text_version, document:) }

          it { is_expected.to be true }

          it "accepts new comments" do
            expect(collaborative_text_suggestion.accepts_new_comments?).to be true
          end

          it "can have comments" do
            suggestion = create(:collaborative_text_suggestion, document_version:)

            expect { create(:comment, commentable: suggestion) }.to change { suggestion.reload.comments_count }.by(1)
          end

          context "when the component is not published" do
            before do
              allow(collaborative_text_suggestion).to receive(:component).and_return(instance_double(Decidim::Component, published?: false))
            end

            it { is_expected.to be false }
          end
        end

        context "when the document is not published" do
          it { is_expected.to be false }

          it "does not accept new comments" do
            expect(collaborative_text_suggestion.accepts_new_comments?).to be false
          end
        end
      end

      describe "#user_allowed_to_comment?" do
        let(:user) { instance_double(Decidim::User) }
        let(:participatory_space) { instance_double(Decidim::ParticipatoryProcess) }

        before do
          allow(collaborative_text_suggestion).to receive(:participatory_space).and_return(participatory_space)
        end

        it "returns false without a user" do
          expect(collaborative_text_suggestion.user_allowed_to_comment?(nil)).to be false
        end

        it "checks participation in the participatory space" do
          allow(participatory_space).to receive(:can_participate?).with(user).and_return(false)

          expect(collaborative_text_suggestion.user_allowed_to_comment?(user)).to be false
          expect(participatory_space).to have_received(:can_participate?).with(user)
        end
      end

      describe "#title" do
        let(:document) { instance_double(Decidim::CollaborativeTexts::Document, title: { "en" => "Document title" }) }

        it "delegates to the document" do
          allow(collaborative_text_suggestion).to receive(:document).and_return(document)

          expect(collaborative_text_suggestion.title).to eq("en" => "Document title")
        end
      end

      describe "#can_participate?" do
        let(:user) { instance_double(Decidim::User) }
        let(:document) { instance_double(Decidim::CollaborativeTexts::Document) }

        it "delegates to the document" do
          allow(collaborative_text_suggestion).to receive(:document).and_return(document)
          allow(document).to receive(:can_participate?).with(user).and_return(true)

          expect(collaborative_text_suggestion.can_participate?(user)).to be true
          expect(document).to have_received(:can_participate?).with(user)
        end
      end

      describe "#users_to_notify_on_comment_created" do
        subject { suggestion.users_to_notify_on_comment_created }

        let(:suggestion) { create(:collaborative_text_suggestion, document_version:, author:) }

        context "when the suggestion author is a user" do
          let(:author) { create(:user, :confirmed, organization: document_version.document.organization) }

          it { is_expected.to contain_exactly(author) }
        end

        context "when the suggestion author is an organization" do
          let(:author) { document_version.document.organization }

          it { is_expected.to be_empty }
        end
      end
    end
  end
end
