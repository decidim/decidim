# frozen_string_literal: true

require "spec_helper"

describe Decidim::ComponentPublishedEvent do
  include Decidim::ComponentPathHelper

  include_context "when a simple event"

  let(:event_name) { "decidim.events.components.component_published" }
  let(:resource) { create(:component) }
  let(:participatory_space) { resource.participatory_space }
  let(:resource_path) { main_component_path(resource) }
  let(:email_subject) { "An update to #{participatory_space_title}" }
  let(:resource_title) { decidim_sanitize_translated(resource.name) }
  let(:participatory_space_title) { decidim_sanitize_translated(participatory_space.title) }
  let(:email_intro) { "The #{decidim_escape_translated(resource.name)} component is now active for #{participatory_space_title}. You can see it from this page:" }
  let(:email_outro) { "You have received this notification because you are following #{participatory_space_title}. You can stop receiving notifications following the previous link." }
  let(:notification_title) { "The #{decidim_escape_translated(resource.name)} component is now active for <a href=\"#{resource_path}\">#{participatory_space_title}</a>" }

  it_behaves_like "a simple event"
  it_behaves_like "a simple event email"
  it_behaves_like "a simple event notification"
end
