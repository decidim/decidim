# frozen_string_literal: true

require "spec_helper"
require "./db/data/20260827000000_generate_avif_variants"
require "./app/jobs/decidim/generate_avif_variant_job"

describe GenerateAvifVariants do
  let(:migrator) do
    described_class.new.tap do |m|
      m.verbose = false
    end
  end

  let(:avatar_path) { File.join(ENV.fetch("ENGINE_ROOT", "."), "spec", "assets", "avatar.jpg") }

  describe "#up" do
    let(:organization) { create(:organization) }
    let(:user) { create(:user, :confirmed, organization:) }

    before do
      user.avatar.attach(
        io: File.open(avatar_path),
        filename: "avatar.jpg",
        content_type: "image/jpeg"
      )
    end

    it "enqueues jobs for user avatars" do
      expect(Decidim::GenerateAvifVariantJob).to receive(:perform_later).exactly(Decidim::AvatarUploader.variants.size).times.with(
        "Decidim::UserBaseEntity",
        user.id,
        :avatar,
        instance_of(Symbol)
      )

      migrator.migrate(:up)
    end

    it "is idempotent" do
      migrator.migrate(:up)
      expect { migrator.migrate(:up) }.not_to raise_error
    end
  end

  describe "#down" do
    it "raises IrreversibleMigration exception" do
      expect { migrator.migrate(:down) }.to raise_error(ActiveRecord::IrreversibleMigration)
    end
  end
end
