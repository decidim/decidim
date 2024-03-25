# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe CleanUnattachedBlobJob do
    it "skips attached files" do
      user = create(:user)

      expect { described_class.perform_now(user.avatar.blob.key) }.not_to change(ActiveStorage::Blob, :count)
      expect(user.reload.avatar).to be_attached
    end

    it "ignores missing blobs" do
      expect { described_class.perform_now("missing") }.not_to raise_error
    end

    it "deletes unattached files" do
      blob = ActiveStorage::Blob.create_and_upload!(io: StringIO.new(Decidim::Dev.asset("import_proposals.csv")), filename: "funky.bin")

      expect(blob.attachments.size).to eq(0)
      expect { described_class.perform_now(blob.key) }.to change(ActiveStorage::Blob, :count).by(-1)
    end
  end
end
