# frozen_string_literal: true

require "spec_helper"

describe Decidim::ParticipatoryProcessStepActivatedEvent do
  include Rails.application.routes.mounted_helpers

  include_context "when a simple event"

  let(:event_name) { "decidim.events.participatory_process.step_activated" }
  let(:participatory_process) { resource.participatory_process }
  let(:participatory_space) { resource.participatory_process }
  let(:resource) { create(:participatory_process_step) }
  let(:resource_path) do
    decidim_participatory_processes.participatory_process_path(participatory_process, display_steps: true)
  end

  let(:resource_url) do
    decidim_participatory_processes
      .participatory_process_url(
        participatory_process,
        display_steps: true,
        host: participatory_process.organization.host
      )
  end

  let(:email_subject) { "An update to #{participatory_space_title}" }
  let(:email_intro) { "The #{resource_title} phase is now active for #{participatory_space_title}. You can see it from this page:" }
  let(:email_outro) { "You have received this notification because you are following #{participatory_space_title}. You can stop receiving notifications following the previous link." }
  let(:notification_title) { "The #{resource_title} phase is now active for <a href=\"#{resource_path}\">#{participatory_space_title}</a>" }

  it_behaves_like "a simple event"
  it_behaves_like "a simple event email"
  it_behaves_like "a simple event notification"
end
