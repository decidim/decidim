# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe GenerateAvifVariantJob do
    subject { described_class }

    describe "queue" do
      it "is queued to default" do
        expect(subject.queue_name).to eq("default")
      end
    end

    describe "perform" do
      let(:organization) { create(:organization) }
      let(:user) { create(:user, :confirmed, organization:) }
      let(:avatar_path) { File.join(ENV.fetch("ENGINE_ROOT", "."), "spec", "assets", "avatar.jpg") }

      before do
        user.avatar.attach(
          io: File.open(avatar_path),
          filename: "avatar.jpg",
          content_type: "image/jpeg"
        )
      end

      context "when the model exists and has an attachment" do
        it "generates the AVIF variant" do
          expect do
            subject.perform_now("Decidim::UserBaseEntity", user.id, :avatar, :big)
          end.not_to raise_error
        end

        it "generates the AVIF variant with avif format" do
          subject.perform_now("Decidim::UserBaseEntity", user.id, :avatar, :big)

          avif_variant = user.attached_uploader(:avatar).avif_variant(:big)
          expect(avif_variant).to respond_to(:processed)
        end
      end

      context "when the model does not exist" do
        it "does not raise an error" do
          expect do
            subject.perform_now("Decidim::UserBaseEntity", 999_999, :avatar, :big)
          end.not_to raise_error
        end
      end

      context "when the attachment is not present" do
        let(:user) { create(:user, :confirmed, organization:) }

        before do
          user.avatar.attach(
            io: File.open(avatar_path),
            filename: "avatar.jpg",
            content_type: "image/jpeg"
          )
          user.avatar.purge
        end

        it "does not raise an error" do
          expect do
            subject.perform_now("Decidim::UserBaseEntity", user.id, :avatar, :big)
          end.not_to raise_error
        end
      end

      context "when variant generation fails" do
        before do
          # rubocop:disable RSpec/AnyInstance
          allow_any_instance_of(Decidim::AvatarUploader).to receive(:avif_variant).and_raise(StandardError, "Test error")
          # rubocop:enable RSpec/AnyInstance
        end

        it "logs a warning instead of raising" do
          expect(Rails.logger).to receive(:warn).with(/AVIF.*Failed to generate variant/)

          expect do
            subject.perform_now("Decidim::UserBaseEntity", user.id, :avatar, :big)
          end.not_to raise_error
        end
      end
    end
  end
end
