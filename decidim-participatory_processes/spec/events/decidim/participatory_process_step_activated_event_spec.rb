# frozen_string_literal: true

require "spec_helper"

describe Decidim::ParticipatoryProcessStepActivatedEvent do
  include Rails.application.routes.mounted_helpers

  include_context "when a simple event"

  let(:event_name) { "decidim.events.participatory_process.step_activated" }
  let(:participatory_process) { resource.participatory_process }
  let(:participatory_space) { resource.participatory_process }
  let(:resource) { create :participatory_process_step }
  let(:resource_path) do
    decidim_participatory_processes.participatory_process_participatory_process_steps_path(participatory_process_slug: participatory_process.slug)
  end

  let(:resource_url) do
    decidim_participatory_processes
      .participatory_process_participatory_process_steps_url(
        participatory_process_slug: participatory_process.slug,
        host: participatory_process.organization.host
      )
  end

  it_behaves_like "a simple event"

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("An update to #{participatory_space_title}")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro)
        .to eq("The #{resource_title} phase is now active for #{participatory_space_title}. You can see it from this page:")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to include("You have received this notification because you are following #{participatory_space_title}")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to eq("The #{resource_title} phase is now active for <a href=\"#{resource_path}\">#{participatory_space_title}</a>")
    end
  end
end
