# frozen_string_literal: true

require "spec_helper"

describe Decidim::Sortitions::CreateSortitionEvent do
  let(:resource) { create(:sortition) }
  let(:notification_title) { "The sortition <a href=\"#{resource_path}\">#{resource_title}</a> has been added to #{participatory_space_title}" }
  let(:email_outro) { "You have received this notification because you are following \"#{participatory_space_title}\". You can unfollow it from the previous link." }
  let(:email_intro) { "The sortition \"#{resource_title}\" has been added to \"#{participatory_space_title}\" that you are following." }
  let(:email_subject) { "New sortition added to #{participatory_space_title}" }
  let(:event_name) { "decidim.events.sortitions.sortition_created" }

  include_context "when a simple event"
  it_behaves_like "a simple event"
  it_behaves_like "a simple event email"
  it_behaves_like "a simple event notification"
end
