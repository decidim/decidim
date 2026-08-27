# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ImageHelper do
    describe "#decidim_picture_tag" do
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

      context "when AVIF variant is available" do
        let(:avif_variant) { user.attached_uploader(:avatar).avif_url(:big) }

        it "renders a picture element with avif source" do
          result = helper.decidim_picture_tag(user, :avatar, variant: :big, image: { alt: "Test avatar", class: "avatar" })

          expect(result).to include("<picture>")
          expect(result).to include('<source srcset="')
          expect(result).to include("<img")
          expect(result).to include('alt="Test avatar"')
          expect(result).to include('class="avatar"')
        end

        it "includes the avif URL in the source tag" do
          result = helper.decidim_picture_tag(user, :avatar, variant: :big)

          expect(result).to include(".avif")
        end

        it "includes the original URL in the img tag" do
          result = helper.decidim_picture_tag(user, :avatar, variant: :big)

          expect(result).to include(".jpg")
        end

        it "passes through additional HTML options" do
          result = helper.decidim_picture_tag(user, :avatar, variant: :big, image: { alt: "Test", loading: "lazy", width: 80, height: 80 })

          expect(result).to include('loading="lazy"')
          expect(result).to include('width="80"')
          expect(result).to include('height="80"')
        end
      end

      context "when AVIF variant is not available" do
        before do
          # rubocop:disable RSpec/AnyInstance
          allow_any_instance_of(Decidim::AvatarUploader).to receive(:avif_url).and_return(nil)
          # rubocop:enable RSpec/AnyInstance
        end

        it "renders a plain img tag" do
          result = helper.decidim_picture_tag(user, :avatar, variant: :big, image: { alt: "Test avatar" })

          expect(result).to include("<picture>")
          expect(result).to include("<img").once
          expect(result).to include('alt="Test avatar"')
        end
      end

      context "when no attachment is present" do
        let(:user) { create(:user, :confirmed, organization:) }

        before do
          user.avatar.attach(
            io: File.open(avatar_path),
            filename: "avatar.jpg",
            content_type: "image/jpeg"
          )
          user.avatar.purge
        end

        it "returns nil" do
          result = helper.decidim_picture_tag(user, :avatar, variant: :big)

          expect(result).to be_nil
        end
      end
    end
  end
end
