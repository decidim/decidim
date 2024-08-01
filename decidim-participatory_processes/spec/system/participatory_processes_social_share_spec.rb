# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/social_share_examples"

describe "Social shares" do
  let(:organization) { create(:organization) }
  let(:process) { create(:participatory_process, organization:, description:, short_description:, hero_image:) }
  let(:content_block) { create(:content_block, organization:, manifest_name: :hero, scope_name: :homepage) }
  let!(:attachment) { create(:attachment, :with_image, attached_to: process, file: attachment_file) }
  let(:description) { { en: "Description <p><img src=\"#{description_image_path}\"></p>" } }
  let(:short_description) { { en: "Description <p><img src=\"#{short_description_image_path}\"></p>" } }
  let(:hero_image) { Decidim::Dev.test_file("city2.jpeg", "image/jpeg") }
  let!(:attachment_file) { Decidim::Dev.test_file("city3.jpeg", "image/jpeg") }
  let(:description_image_path) { Rails.application.routes.url_helpers.rails_blob_path(description_image, only_path: true) }
  let(:description_image) do
    ActiveStorage::Blob.create_and_upload!(
      io: File.open(Decidim::Dev.asset("city.jpeg")),
      filename: "description_image.jpg",
      content_type: "image/jpeg"
    )
  end
  let(:short_description_image_path) { Rails.application.routes.url_helpers.rails_blob_path(short_description_image, only_path: true) }
  let(:short_description_image) do
    ActiveStorage::Blob.create_and_upload!(
      io: File.open(Decidim::Dev.asset("city.jpeg")),
      filename: "short_description_image.jpg",
      content_type: "image/jpeg"
    )
  end
  let(:block_attachment_file) { Decidim::Dev.test_file("icon.png", "image/png") }
  let(:resource) { process }

  before do
    if content_block
      content_block.images_container.background_image = block_attachment_file
      content_block.save!
    end
    switch_to_host(organization.host)
  end

  it_behaves_like "a social share meta tag", "city2.jpeg"
  context "when no hero_image" do
    let(:hero_image) { nil }

    it_behaves_like "a social share meta tag", "city3.jpeg"
  end

  context "when no attachments nor direct images" do
    let(:hero_image) { nil }
    let(:attachment) { nil }

    it_behaves_like "a social share meta tag", "description_image.jpg"

    context "and only short description image" do
      let(:description_image_path) { "" }

      it_behaves_like "a social share meta tag", "short_description_image.jpg"
    end
  end

  context "when no attachments, description image or direct images" do
    let(:hero_image) { nil }
    let(:attachment) { nil }
    let(:description_image_path) { "" }
    let(:short_description_image_path) { "" }

    it_behaves_like "a social share meta tag", "icon.png"
  end

  context "when nothing" do
    let(:hero_image) { nil }
    let(:attachment) { nil }
    let(:description_image_path) { "" }
    let(:short_description_image_path) { "" }
    let(:content_block) { nil }

    it_behaves_like "a empty social share meta tag"
  end

  context "when listing all processes" do
    let(:resource) { decidim_participatory_processes.participatory_processes_path }

    it_behaves_like "a social share meta tag", "icon.png"
  end

  context "when listing a process group" do
    let!(:participatory_process_group) { create(:participatory_process_group, organization:, description:, hero_image:) }
    let(:resource) { decidim_participatory_processes.participatory_process_group_path(participatory_process_group) }

    it_behaves_like "a social share meta tag", "city2.jpeg"

    context "when no hero_image" do
      let(:hero_image) { nil }

      it_behaves_like "a social share meta tag", "description_image.jpg"
    end

    context "when no direct images nor description images" do
      let(:hero_image) { nil }
      let(:description_image_path) { "" }

      it_behaves_like "a social share meta tag", "icon.png"
    end
  end
end
