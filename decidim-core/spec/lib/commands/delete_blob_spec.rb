# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Commands
    describe DeleteBlob do
      subject { described_class.new(blob, user) }

      let(:organization) { create(:organization) }
      let(:user) { create(:user, :confirmed, organization:) }
      let(:attachment) { create(:attachment, :with_image, attached_to: create(:participatory_process, organization:)) }
      let(:blob) { attachment.reload.file_blob }

      context "when the blob is attached to a record" do
        it "broadcasts ok" do
          expect { subject.call }.to broadcast(:ok)
        end

        it "destroys the attachment record which uses the blob" do
          blob

          expect { subject.call }.to change(Decidim::Attachment, :count).by(-1)
        end

        it "purges the blob" do
          blob

          expect { perform_enqueued_jobs { subject.call } }.to change { ActiveStorage::Blob.exists?(blob.id) }.from(true).to(false)
        end

        it "traces the action", versioning: true do
          expect(Decidim.traceability)
            .to receive(:perform_action!)
            .with(:delete, blob, user)
            .and_call_original

          expect { subject.call }.to change(Decidim::ActionLog, :count)

          action_log = Decidim::ActionLog.last
          expect(action_log.action).to eq("delete")
          expect(action_log.user).to eq(user)
          expect(action_log.resource).to eq(blob)
        end
      end

      context "when the blob is not attached to any record" do
        let(:blob) { ActiveStorage::Blob.create_and_upload!(io: Decidim::Dev.test_file("city.jpeg", "image/jpeg"), filename: "city.jpeg") }

        it "broadcasts invalid" do
          expect { subject.call }.to broadcast(:invalid)
        end

        it "does not delete the blob" do
          blob
          user

          expect { subject.call }.not_to change(ActiveStorage::Blob, :count)
        end
      end
    end
  end
end
