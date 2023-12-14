# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::CollaborativeDraftAccessAcceptedEvent do
  include_context "when a simple event"

  let(:event_name) { "decidim.events.proposals.collaborative_draft_access_accepted" }
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
  let(:requester_presenter) { Decidim::UserPresenter.new(requester) }
  let(:requester_id) { requester.id }
  let(:requester_name) { requester.name }
  let(:requester_nickname) { requester_presenter.nickname }
  let(:requester_path) { requester_presenter.profile_path }
  let(:extra) { { requester_id: } }

  context "when the notification is for coauthor users" do
    let(:email_subject) { "#{requester_name} has been accepted to access as a contributor of the #{resource_title}." }
    let(:email_intro) { %(#{requester_name} has been accepted to access as a contributor of the <a href="#{resource_url}">#{decidim_html_escape(resource_title)}</a> collaborative draft.) }
    let(:email_outro) { %(You have received this notification because you are a collaborator of <a href="#{resource_url}">#{decidim_html_escape(resource_title)}</a>.) }
    let(:notification_title) { %(<a href="#{requester_path}">#{requester_name} #{requester_nickname}</a> has been <strong>accepted to access as a contributor</strong> of the <a href="#{resource_path}">#{decidim_html_escape(resource_title)}</a> collaborative draft.) }

    it_behaves_like "a simple event"
    it_behaves_like "a simple event email"
    it_behaves_like "a simple event notification"
  end

  context "when the notification is for the requester" do
    let(:event_name) { "decidim.events.proposals.collaborative_draft_access_requester_accepted" }
    let(:email_subject) { "You have been accepted as a contributor of #{resource_title}." }
    let(:email_intro) { %(You have been accepted to access as a contributor of the <a href="#{resource_url}">#{decidim_html_escape(resource_title)}</a> collaborative draft.) }
    let(:email_outro) { %(You have received this notification because you requested to become a collaborator of <a href="#{resource_url}">#{decidim_html_escape(resource_title)}</a>.) }
    let(:notification_title) { %(You have been <strong>accepted to access as a contributor</strong> of the <a href="#{resource_path}">#{decidim_html_escape(resource_title)}</a> collaborative draft.) }

    it_behaves_like "a simple event"
    it_behaves_like "a simple event email"
    it_behaves_like "a simple event notification"
  end
end
