# frozen_string_literal: true

require "spec_helper"

describe "rake decidim:attachments_cleanup", type: :task do
  around do |example|
    perform_enqueued_jobs { example.run }
  end

  let!(:old_blob) do
    ActiveStorage::Blob.create_and_upload!(
      io: File.open(Decidim::Dev.asset("city.jpeg")),
      filename: "city.jpeg",
      content_type: "image/jpeg"
    ).tap do |blob|
      # rubocop:disable-next Rails/SkipsModelValidations
      blob.update_column(:created_at, 2.hours.ago)
    end
  end

  let!(:recent_blob) do
    ActiveStorage::Blob.create_and_upload!(
      io: File.open(Decidim::Dev.asset("city2.jpeg")),
      filename: "city2.jpeg",
      content_type: "image/jpeg"
    )
  end

  let!(:attached_blob) do
    create(:attachment, :with_image, attached_to: create(:dummy_resource)).file_blob
  end

  it "purges the unattached blobs older than the cleanup window" do
    expect { task.execute }.to change { ActiveStorage::Blob.exists?(old_blob.id) }.from(true).to(false)
  end

  it "keeps the unattached blobs newer than the cleanup window" do
    task.execute

    expect(ActiveStorage::Blob.exists?(recent_blob.id)).to be(true)
  end

  it "keeps the blobs attached to records" do
    task.execute

    expect(ActiveStorage::Blob.exists?(attached_blob.id)).to be(true)
  end

  context "with a custom cleanup window" do
    it "purges the unattached blobs older than the provided minutes" do
      expect { task.execute(clean_up_unattached_blobs_after_in_minutes: 0) }
        .to change { ActiveStorage::Blob.exists?(recent_blob.id) }.from(true).to(false)
    end
  end
end
