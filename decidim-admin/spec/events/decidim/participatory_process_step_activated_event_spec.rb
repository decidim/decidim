# frozen_string_literal: true

require "spec_helper"

describe Decidim::ParticipatoryProcessStepActivatedEvent do
  include Rails.application.routes.mounted_helpers
  subject do
    described_class.new(resource: process_step, event_name: event_name, user: follower, extra: {})
  end

  let(:organization) { follower.organization }
  let(:follower) { create :user }
  let(:event_name) { "decidim.events.participatory_process_step_activated_event" }
  let(:participatory_process) { process_step.participatory_process }
  let(:resource_path) do
    decidim_participatory_processes.participatory_process_participatory_process_steps_path(participatory_process)
  end
  let(:process_step) { create :participatory_process_step }

  describe "types" do
    subject { described_class }

    it "supports notifications" do
      expect(subject.types).to include :notification
    end

    it "supports emails" do
      expect(subject.types).to include :email
    end
  end

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("An update to #{participatory_process.title["en"]}")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro)
        .to eq("The #{process_step.title["en"]} step is now active for #{participatory_process.title["en"]}. You can see it from this page:")
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
        .to eq("The #{process_step.title["en"]} step is now active for <a href=\"#{resource_path}\">#{participatory_process.title["en"]}</a>")
    end
  end
end
