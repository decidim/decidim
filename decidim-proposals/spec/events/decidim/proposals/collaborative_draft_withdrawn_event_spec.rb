# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::CollaborativeDraftWithdrawnEvent do
  include_context "when a simple event"

  let(:event_name) { "decidim.events.proposals.collaborative_draft_withdrawn" }
  let(:resource) { create(:collaborative_draft, title: "It is my collaborative draft") }
  let(:resource_path) { Decidim::ResourceLocatorPresenter.new(resource).path }
  let(:resource_title) { decidim_html_escape(resource.title) }
  let(:author) { resource.authors.first }
  let(:author_id) { author.id }
  let(:author_presenter) { Decidim::UserPresenter.new(author) }
  let(:author_path) { author_presenter.profile_path }
  let(:author_url) { author_presenter.profile_url }
  let(:author_name) { author_presenter.name }
  let(:author_nickname) { author_presenter.nickname }
  let(:extra) { { author_id: } }

  context "when the notification is for coauthor users" do
    let(:notification_title) { %(<a href="#{author_path}">#{author_name} #{author_nickname}</a> <strong>withdrawn</strong> the <a href="#{resource_path}">#{resource_title}</a> collaborative draft.) }
    let(:email_outro) { %(You have received this notification because you are a collaborator of <a href="#{resource_url}">#{resource_title}</a>.) }
    let(:email_intro) { %(<a href="#{author_url}">#{author_name} #{author_nickname}</a> withdrawn the <a href="#{resource_url}">#{resource_title}</a> collaborative draft.) }
    let(:email_subject) { "#{author_name} #{author_nickname} withdrawn the #{decidim_sanitize(resource_title)} collaborative draft." }

    it_behaves_like "a simple event"
    it_behaves_like "a simple event email"
    it_behaves_like "a simple event notification"
  end
end
