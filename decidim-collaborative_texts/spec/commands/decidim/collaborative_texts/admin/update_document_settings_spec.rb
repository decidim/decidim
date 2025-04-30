# frozen_string_literal: true

require "spec_helper"

module Decidim
  module CollaborativeTexts
    module Admin
      describe UpdateDocumentSettings do
        subject { described_class.new(form, document) }

        let(:document) { create(:collaborative_text_document, :with_body) }
        let(:organization) { document.component.organization }
        let(:user) { create(:user, :admin, :confirmed, organization:) }
        let(:accepting_suggestions) { false }
        let(:announcement) { ::Faker::HTML.paragraph }
        let(:form) do
          double(
            invalid?: invalid,
            current_user: user,
            accepting_suggestions:,
            announcement:
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
          it "updates the document" do
            subject.call
            expect(document.accepting_suggestions).to eq accepting_suggestions
            expect(document.announcement).to eq announcement
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:update!)
              .with(document, user, hash_including(:accepting_suggestions, :announcement))
              .and_call_original

            expect { subject.call }.to change(Decidim::ActionLog, :count)
            action_log = Decidim::ActionLog.last
            expect(action_log.version).to be_present
            expect(action_log.version.event).to eq "update"
          end
        end
      end
    end
  end
end
