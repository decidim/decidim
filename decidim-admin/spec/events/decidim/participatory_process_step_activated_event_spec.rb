# frozen_string_literal: true

require "spec_helper"

describe Decidim::ParticipatoryProcessStepActivatedEvent do
  include Rails.application.routes.mounted_helpers

  include_context "simple event"

  let(:event_name) { "decidim.events.participatory_process.step_activated" }
  let(:participatory_process) { resource.participatory_process }
  let(:resource) { create :participatory_process_step }
  let(:resource_path) do
    decidim_participatory_processes
      .participatory_process_participatory_process_steps_path(participatory_process)
  end

  it_behaves_like "a simple event"

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("An update to #{participatory_process.title["en"]}")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro)
        .to eq("The #{resource_title} step is now active for #{participatory_process.title["en"]}. You can see it from this page:")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to include("You have received this notification because you are following #{participatory_process.title["en"]}")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to eq("The #{resource_title} step is now active for <a href=\"#{resource_path}\">#{participatory_process.title["en"]}</a>")
    end
  end
end
