# frozen_string_literal: true

require "spec_helper"

module Decidim
  module CollaborativeTexts
    module Admin
      describe UnpublishDocument, type: :command do
        let(:organization) { create(:organization, available_locales: [:en]) }
        let(:document) { create(:collaborative_text_document, :with_body, published_at: Time.current, title: "This is and original document test title") }
        let(:current_user) { create(:user, :admin, :confirmed, organization:) }
        let(:command) { described_class.new(document, current_user) }

        describe "call" do
          context "when the collaborative text document is published" do
            it "unpublishes the collaborative text document" do
              expect(Decidim.traceability).to receive(:perform_action!).with(
                :unpublish,
                document,
                current_user
              ).and_call_original

              expect(command).to broadcast(:ok, document)
              expect(document.reload).not_to be_published
            end
          end

          context "when the collaborative text document is not published" do
            before do
              document.update!(published_at: nil)
            end

            it "does not unpublish the collaborative text document" do
              expect { command.call }.not_to(change { document.reload.published_at })

              expect(command).to broadcast(:invalid)
            end
          end
        end
      end
    end
  end
end
