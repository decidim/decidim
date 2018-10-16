# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Consultations
    module Admin
      describe PublishConsultation do
        subject { described_class.new(consultation, current_user) }

        let(:consultation) { create :consultation, :unpublished }
        let(:current_user) { create :user, :admin, organization: consultation.organization }

        context "when the consultation is nil" do
          let(:consultation) { nil }
          let(:current_user) { nil }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when the consultation is published" do
          let(:consultation) { create :consultation, :published }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when the consultation is not published" do
          it "is valid" do
            expect { subject.call }.to broadcast(:ok)
          end

          it "publishes it" do
            subject.call
            consultation.reload
            expect(consultation).to be_published
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with(
                "publish",
                consultation,
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
