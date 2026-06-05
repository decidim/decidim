# frozen_string_literal: true

require "spec_helper"

describe "rake decidim:upgrade:clean:remove_private_exports_attachments", type: :task do
  around do |example|
    perform_enqueued_jobs { example.run }
  end

  context "when executing task" do
    it "does not throw exceptions keys" do
      expect do
        Rake::Task[:"decidim:upgrade:clean:remove_private_exports_attachments"].invoke
      end.not_to raise_exception
    end
  end

  context "when there are no errors" do
    let(:filename) { "avatar.jpg" }
    let(:content_type) { "image/jpeg" }
    let(:blob) { ActiveStorage::Blob.create_and_upload!(io: File.open(Decidim::Dev.asset(filename)), filename:, content_type:) }
    let(:attachment) { ActiveStorage::Attachment.create!(name: "file", record: create(:dummy_resource), blob:) }

    it "removes ActiveStorage entries" do
      # rubocop:disable Rails/SkipsModelValidations
      ActiveStorage::Attachment.where(id: attachment.id).update_all(record_type: "Decidim::PrivateExport", record_id: 0)
      # rubocop:enable Rails/SkipsModelValidations
      expect { task.execute }.to change(ActiveStorage::Attachment, :count)
    end
  end

  context "when removes attachments of expired exports" do
    let!(:exports) { create(:private_export, :expired) }

    it "removes ActiveStorage entries" do
      expect { task.execute }.to change(ActiveStorage::Attachment, :count)
    end
  end
end
