# frozen_string_literal: true

require "spec_helper"

module Decidim
  module CollaborativeTexts
    module Admin
      describe PublishCollaborativeText, type: :command do
        let(:organization) { create(:organization, available_locales: [:en]) }
        let(:collaborative_text_document) { create(:collaborative_text_document, published_at: nil, title: "This is and original document test title") }
        let(:current_user) { create(:user, :admin, :confirmed, organization:) }
        let(:command) { described_class.new(collaborative_text_document, current_user) }

        describe "call" do
          context "when the collaborative text document is not already published" do
            it "publishes the collaborative text document" do
              expect(Decidim.traceability).to receive(:perform_action!).with(
                :publish,
                collaborative_text_document,
                current_user,
                visibility: "all"
              ).and_call_original

              expect(command).to broadcast(:ok, collaborative_text_document)
            end
          end

          context "when the collaborative text document is already published" do
            before do
              collaborative_text_document.update!(published_at: Time.current)
            end

            it "does not publish the collaborative text document" do
              expect { command.call }.not_to(change { collaborative_text_document.reload.published_at })

              expect(command).to broadcast(:invalid)
            end
          end
        end
      end
    end
  end
end
