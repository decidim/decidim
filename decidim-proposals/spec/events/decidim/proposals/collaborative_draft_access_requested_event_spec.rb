# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::CollaborativeDraftAccessRequestedEvent do
  include_context "when a simple event"

  let(:event_name) { "decidim.events.proposals.collaborative_draft_access_requested" }
  let(:resource) { create(:collaborative_draft, title: "It is my collaborative draft") }
  let(:resource_path) { Decidim::ResourceLocatorPresenter.new(resource).path }
  let(:resource_title) { resource.title }
  let(:author) { resource.authors.first }
  let(:author_id) { author.id }
  let(:author_presenter) { Decidim::UserPresenter.new(author) }
  let(:author_path) { author_presenter.profile_path }
  let(:author_name) { author_presenter.name }
  let(:author_nickname) { author_presenter.nickname }
  let(:requester) { create(:user, :confirmed, organization: resource.organization) }
  let(:requester_name) { requester.name }
  let(:requester_id) { requester.id }
  let(:requester_presenter) { Decidim::UserPresenter.new(requester) }
  let(:requester_path) { requester_presenter.profile_path }
  let(:requester_nickname) { requester_presenter.nickname }
  let(:extra) { { requester_id: } }

  context "when the notification is for coauthor users" do
    let(:notification_title) { %(<a href="#{requester_path}">#{requester_name} #{requester_nickname}</a> requested access to contribute to the <a href="#{resource_path}">#{decidim_html_escape(resource_title)}</a> collaborative draft. Please <strong>accept or reject the request</strong>.) }
    let(:email_outro) { %(You have received this notification because you are a collaborator of <a href="#{resource_url}">#{decidim_html_escape(resource_title)}</a>.) }
    let(:email_intro) { %(#{requester_name} requested access as a contributor. You can <strong>accept or reject the request</strong> from the <a href="#{resource_url}">#{decidim_html_escape(resource_title)}</a> collaborative draft page.) }
    let(:email_subject) { "#{requester_name} requested access to contribute to #{resource_title}." }

    it_behaves_like "a simple event"
    it_behaves_like "a simple event email"
    it_behaves_like "a simple event notification"
  end
end
