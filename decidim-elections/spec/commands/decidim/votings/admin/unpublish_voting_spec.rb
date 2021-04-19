# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Votings
    module Admin
      describe UnpublishVoting do
        subject { described_class.new(voting, current_user) }

        let(:voting) { create :voting, :published }
        let(:current_user) { create :user, :admin, organization: voting.organization }

        context "when the voting is nil" do
          let(:voting) { nil }
          let(:current_user) { nil }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when the voting is not published" do
          let(:voting) { create :voting, :unpublished }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when the voting is published" do
          it "is valid" do
            expect { subject.call }.to broadcast(:ok)
          end

          it "unpublishes it" do
            subject.call
            voting.reload
            expect(voting).not_to be_published
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with(
                :unpublish,
                voting,
                current_user,
                visibility: "all"
              )
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
