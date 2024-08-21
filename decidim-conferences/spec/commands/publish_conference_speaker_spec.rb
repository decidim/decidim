# frozen_string_literal: true

require "spec_helper"
module Decidim
  module Conferences
    module Admin
      describe PublishConferenceSpeaker, type: :command do
        let(:organization) { create(:organization, available_locales: [:en]) }
        let(:conference_speaker) { create(:conference_speaker, published_at: nil) }
        let(:current_user) { create(:user, :admin, :confirmed, organization:) }
        let(:command) { described_class.new(conference_speaker, current_user) }

        describe "call" do
          context "when the conference speaker is not already published" do
            it "publishes the conference speaker" do
              expect(Decidim.traceability).to receive(:perform_action!).with(
                :publish,
                conference_speaker,
                current_user
              ).and_call_original

              expect(command).to broadcast(:ok, conference_speaker)
            end
          end

          context "when the conference speaker is already published" do
            before do
              conference_speaker.update!(published_at: Time.current)
            end

            it "does not publish the conference speaker" do
              expect { command.call }.not_to(change { conference_speaker.reload.published_at })

              expect(command).to broadcast(:invalid)
            end
          end
        end
      end
    end
  end
end
