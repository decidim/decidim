# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/social_share_examples"

describe "Social shares" do
  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, hero_image:, organization:) }
  let(:hero_image) { Decidim::Dev.test_file("city2.jpeg", "image/jpeg") }
  let(:component) { create(:debates_component, participatory_space: participatory_process) }
  let(:debate) { create(:debate, component:, description:) }
  let(:content_block) { create(:content_block, organization:, manifest_name: :hero, scope_name: :homepage) }
  let(:description) { { en: "Description <p><img src=\"#{description_image_path}\"></p>" } }
  let(:description_image_path) { Rails.application.routes.url_helpers.rails_blob_path(description_image, only_path: true) }
  let(:description_image) do
    ActiveStorage::Blob.create_and_upload!(
      io: File.open(Decidim::Dev.asset("city.jpeg")),
      filename: "description_image.jpg",
      content_type: "image/jpeg"
    )
  end
  let(:block_attachment_file) { Decidim::Dev.test_file("icon.png", "image/png") }
  let(:resource) { debate }

  before do
    if content_block
      content_block.images_container.background_image = block_attachment_file
      content_block.save!
    end
    switch_to_host(organization.host)
  end

  it_behaves_like "a social share meta tag", "city2.jpeg"
  it_behaves_like "a social share widget"
  it_behaves_like "a social share via QR code" do
    context "when the resource is moderated" do
      let(:debate) { create(:debate, component:, description:) }

      before do
        create(:moderation, reportable: debate, hidden_at: 1.day.ago)
      end

      it_behaves_like "a 404 page" do
        let(:target_path) { decidim.qr_path(resource: debate.to_sgid.to_s) }
      end
    end

    context "when the resource's component is not published" do
      let(:component) { create(:debates_component, :unpublished, participatory_space: participatory_process) }
      let(:debate) { create(:debate, component:, description:) }

      it_behaves_like "a 404 page" do
        let(:target_path) { decidim.qr_path(resource: debate.to_sgid.to_s) }
      end
    end

    context "when the resource's space is not published" do
      let(:participatory_process) { create(:participatory_process, :unpublished, hero_image:, organization:) }
      let(:debate) { create(:debate, component:, description:) }

      it_behaves_like "a 404 page" do
        let(:target_path) { decidim.qr_path(resource: debate.to_sgid.to_s) }
      end
    end
  end

  context "when no description images" do
    let(:description_image_path) { "" }

    it_behaves_like "a social share meta tag", "city2.jpeg"
  end

  context "when listing all debates" do
    let(:resource) { main_component_path(component) }

    it_behaves_like "a social share meta tag", "city2.jpeg"
  end
end
