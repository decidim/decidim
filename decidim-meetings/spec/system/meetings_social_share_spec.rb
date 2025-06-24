# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/shared_examples/social_share_examples"

describe "Social shares" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization:) }
  let(:participatory_process) { create(:participatory_process, hero_image:, organization:) }
  let(:hero_image) { Decidim::Dev.test_file("city2.jpeg", "image/jpeg") }
  let(:component) { create(:meeting_component, participatory_space: participatory_process) }
  let(:meeting) { create(:meeting, :published, component:, description:) }
  let(:content_block) { create(:content_block, organization:, manifest_name: :hero, scope_name: :homepage) }
  let!(:attachment) { create(:attachment, :with_image, attached_to: meeting, file: attachment_file) }
  let(:description) { { en: "Description <p><img src=\"#{description_image_path}\"></p>" } }
  let!(:attachment_file) { Decidim::Dev.test_file("city3.jpeg", "image/jpeg") }
  let(:description_image_path) { Rails.application.routes.url_helpers.rails_blob_path(description_image, only_path: true) }
  let(:description_image) do
    ActiveStorage::Blob.create_and_upload!(
      io: File.open(Decidim::Dev.asset("city.jpeg")),
      filename: "description_image.jpg",
      content_type: "image/jpeg"
    )
  end
  let(:block_attachment_file) { Decidim::Dev.test_file("icon.png", "image/png") }
  let(:resource) { meeting }

  before do
    stub_geocoding_coordinates([meeting.latitude, meeting.longitude])
    if content_block
      content_block.images_container.background_image = block_attachment_file
      content_block.save!
    end
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  it_behaves_like "a social share meta tag", "city3.jpeg"
  it_behaves_like "a social share widget"

  context "when no attachment images" do
    let!(:attachment) { nil }

    it_behaves_like "a social share meta tag", "description_image.jpg"
  end

  context "when no attachments nor description images" do
    let(:attachment) { nil }
    let(:description_image_path) { "" }

    it_behaves_like "a social share meta tag", "city2.jpeg"
  end

  context "when listing all meetings" do
    let(:resource) { main_component_path(component) }

    it_behaves_like "a social share meta tag", "city2.jpeg"
  end

  context "when visiting a poll" do
    let!(:poll) { create(:poll, meeting:) }
    let!(:meetings_poll_questionnaire) { create(:meetings_poll_questionnaire, questionnaire_for: poll) }
    let!(:meeting_polls_question) { create(:meetings_poll_question, :published, questionnaire: meetings_poll_questionnaire) }
    let(:resource) { Decidim::EngineRouter.main_proxy(component).meeting_polls_answers_path(meeting) }

    it_behaves_like "a social share meta tag", "city3.jpeg"
  end

  context "when visiting live events" do
    let(:meeting) { create(:meeting, :published, :online, :live, component:, description:) }
    let(:resource) { Decidim::EngineRouter.main_proxy(component).meeting_live_event_path(meeting) }

    it_behaves_like "a social share meta tag", "city3.jpeg"
  end
end
