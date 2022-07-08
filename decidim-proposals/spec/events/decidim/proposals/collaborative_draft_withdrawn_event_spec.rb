# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::CollaborativeDraftWithdrawnEvent do
  include_context "when a simple event"

  let(:event_name) { "decidim.events.proposals.collaborative_draft_withdrawn" }
  let(:resource) { create :collaborative_draft, title: "It's my collaborative draft" }
  let(:resource_path) { Decidim::ResourceLocatorPresenter.new(resource).path }
  let(:resource_title) { decidim_html_escape(resource.title) }
  let(:author) { resource.authors.first }
  let(:author_id) { author.id }
  let(:author_presenter) { Decidim::UserPresenter.new(author) }
  let(:author_path) { author_presenter.profile_path }
  let(:author_url) { author_presenter.profile_url }
  let(:author_name) { author_presenter.name }
  let(:author_nickname) { author_presenter.nickname }
  let(:extra) { { author_id: author_id } }

  context "when the notification is for coauthor users" do
    it_behaves_like "a simple event"

    describe "email_subject" do
      it "is generated correctly" do
        expect(subject.email_subject).to eq("#{author_name} #{author_nickname} withdrawn the #{decidim_sanitize(resource_title)} collaborative draft.")
      end
    end

    describe "email_intro" do
      it "is generated correctly" do
        expect(subject.email_intro)
          .to eq(%(<a href="#{author_url}">#{author_name} #{author_nickname}</a> withdrawn the <a href="#{resource_url}">#{resource_title}</a> collaborative draft.))
      end
    end

    describe "email_outro" do
      it "is generated correctly" do
        expect(subject.email_outro)
          .to eq(%(You have received this notification because you are a collaborator of <a href="#{resource_url}">#{resource_title}</a>.))
      end
    end

    describe "notification_title" do
      it "is generated correctly" do
        expect(subject.notification_title)
          .to include(%(<a href="#{author_path}">#{author_name} #{author_nickname}</a> <strong>withdrawn</strong> the <a href="#{resource_path}">#{resource_title}</a> collaborative draft.))
      end
    end
  end
end
