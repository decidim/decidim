# frozen_string_literal: true

require "spec_helper"

describe Decidim::UserGroupUpdatedEvent do
  include_context "when a simple event"

  let(:event_name) { "decidim.events.groups.user_group_updated" }
  let(:resource) { create(:user_group) }
  let(:user_group_name) { escaped_html(resource.name) }
  let(:admin_panel_url) { "http://#{organization.host}/admin/user_groups" }
  let(:email_subject) { "A user group has updated its profile" }
  let(:email_intro) { %(A user group with the name #{user_group_name} has updated its profile, leaving it unverified. You can now verify it in the <a href="#{admin_panel_url}">admin panel</a>.) }
  let(:email_outro) { "You have received this notification because you are an admin of the platform." }
  let(:notification_title) { %(The #{user_group_name} user group has updated its profile, leaving it unverified. You can now verify it in the <a href="/admin/user_groups">admin panel</a>.) }

  it_behaves_like "a simple event", true
  it_behaves_like "a simple event email"
  it_behaves_like "a simple event notification"
end
