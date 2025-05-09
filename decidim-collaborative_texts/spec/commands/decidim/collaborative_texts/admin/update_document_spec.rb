# frozen_string_literal: true

require "spec_helper"

module Decidim
  module CollaborativeTexts
    module Admin
      describe UpdateDocument do
        subject { described_class.new(form, document) }

        let!(:document) { create(:collaborative_text_document, :with_body) }
        let(:organization) { document.component.organization }
        let(:user) { create(:user, :admin, :confirmed, organization:) }
        let(:title) { "This is my document new title" }
        let(:body) { ::Faker::HTML.paragraph }
        let(:accepting_suggestions) { true }
        let(:draft) { false }
        let(:form) do
          double(
            invalid?: invalid,
            current_user: user,
            title:,
            body:,
            draft?: draft,
            draft: draft,
            accepting_suggestions:,
            coauthorships: [Decidim::Coauthorship.new(author: organization)]
          )
        end
        let(:invalid) { false }
        let(:first_version) { Decidim::CollaborativeTexts::Version.first }
        let(:last_version) { Decidim::CollaborativeTexts::Version.last }

        context "when the form is not valid" do
          let(:invalid) { true }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        shared_examples "updates the same version" do
          it "updates document and version" do
            expect { subject.call }.not_to change(Decidim::CollaborativeTexts::Version, :count)
            expect(first_version).to eq last_version
            expect(last_version).to eq document.current_version
            expect(last_version.body).to eq body unless document.has_suggestions?
            expect(last_version.draft).to eq draft
            expect(last_version.document).to eq document
            expect(document.reload.title).to eq title
            expect(document.accepting_suggestions).to eq accepting_suggestions
          end

          it "traces the action", versioning: true do
            updated_keys = { draft: }
            updated_keys[:body] = body unless document.has_suggestions?
            expect(Decidim.traceability)
              .to receive(:update!)
              .with(document, user, { title:, accepting_suggestions: }, {
                      extra: {
                        version_id: last_version.id,
                        version_number: 1
                      }
                    })
              .and_call_original
            expect(Decidim.traceability)
              .to receive(:update!)
              .with(last_version, user, updated_keys, {
                      extra: {
                        document_id: document.id,
                        title: title,
                        version_number: 1
                      },
                      resource: {
                        title: title
                      },
                      participatory_space: {
                        title: document.participatory_space.title
                      }
                    })
              .and_call_original

            expect { subject.call }.to change(Decidim::ActionLog, :count).by(2)
            first_log, second_log = Decidim::ActionLog.last(2)
            expect(first_log.version).to be_present
            expect(first_log.extra["extra"]).to eq({ "version_id" => last_version.id, "version_number" => 1 })
            expect(second_log.version).to be_present
            expect(second_log.extra["extra"]).to eq({ "document_id" => document.id, "title" => title, "version_number" => 1 })
          end
        end

        shared_examples "creates a new version" do
          it "updates document and creates a new version" do
            expect { subject.call }.to change(Decidim::CollaborativeTexts::Version, :count).by(1)
            expect(first_version).not_to eq last_version
            expect(last_version).to eq document.current_version
            expect(last_version.body).to eq first_version.body
            expect(last_version.draft).to eq draft
            expect(last_version.document).to eq document
            expect(document.reload.title).to eq title
            expect(document.accepting_suggestions).to eq accepting_suggestions
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:update!)
              .with(document, user, { title:, accepting_suggestions: }, {
                      extra: {
                        version_id: last_version.id,
                        version_number: 2
                      }
                    })
              .and_call_original
            expect(Decidim.traceability)
              .to receive(:create!)
              .with(Decidim::CollaborativeTexts::Version, user, { document:, body: document.body, draft: true }, {
                      extra: {
                        document_id: document.id,
                        title: title,
                        version_number: 2
                      },
                      resource: {
                        title: title
                      },
                      participatory_space: {
                        title: document.participatory_space.title
                      }
                    })
              .and_call_original

            expect { subject.call }.to change(Decidim::ActionLog, :count).by(2)
            first_log, last_log = Decidim::ActionLog.last(2)
            expect(first_log.version).to be_present
            expect(first_log.extra["extra"]).to eq({ "version_id" => last_version.id, "version_number" => 2 })
            expect(last_log.version).to be_present
            expect(last_log.extra["extra"]).to eq({ "document_id" => document.id, "title" => title, "version_number" => 2 })
          end
        end

        context "when everything is ok" do
          it_behaves_like "updates the same version"

          context "and there are no coauthorships" do
            before do
              Decidim::Coauthorship.destroy_all
              document.reload
            end

            it "creates a new coauthorship" do
              expect { subject.call }.to change(Decidim::Coauthorship, :count).by(1)
              expect(Decidim::Coauthorship.last.author).to eq organization
            end
          end

          context "and we want draft" do
            let(:draft) { true }

            it_behaves_like "updates the same version"
          end

          context "and there are suggestions" do
            before do
              create(:collaborative_text_suggestion, document_version: document.current_version, author: user)
            end

            it_behaves_like "updates the same version"

            context "and we want draft" do
              let(:draft) { true }

              it_behaves_like "creates a new version"
            end
          end
        end
      end
    end
  end
end
