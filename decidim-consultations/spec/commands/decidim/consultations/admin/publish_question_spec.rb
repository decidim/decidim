# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Consultations
    module Admin
      describe PublishQuestion do
        subject { described_class.new(question, user) }

        let(:question) { create :question, :unpublished }
        let(:user) { create(:user, organization: question.organization) }

        context "when the consultation is nil" do
          let(:question) { nil }
          let(:user) { nil }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when the question is published" do
          let(:question) { create :question, :published }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when the question is not published" do
          it "is valid" do
            expect { subject.call }.to broadcast(:ok)
          end

          it "publishes it" do
            subject.call
            question.reload
            expect(question).to be_published
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with("publish", question, user, visibility: "all")
              .and_call_original

            expect { subject.call }.to change(Decidim::ActionLog, :count)
            action_log = Decidim::ActionLog.last
            expect(action_log.version).to be_present
          end
        end
      end
    end
  end
end
