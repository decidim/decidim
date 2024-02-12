# frozen_string_literal: true

require "spec_helper"

describe Decidim::Initiatives::RevokeMembershipRequestEvent do
  include_context "when a simple event"

  let(:user_role) { :affected_user }
  let(:extra) { { author: } }
  let(:event_name) { "decidim.events.initiatives.approve_membership_request" }
  let(:organization) { create(:organization) }
  let!(:resource) { create(:initiative, :created, organization:) }
  let(:author) { resource.author }
  let(:author_profile_url) { Decidim::UserPresenter.new(author).profile_url }
  let(:author_nickname) { Decidim::UserPresenter.new(author).nickname }
  let(:user) { create(:initiatives_committee_member, initiative: resource, state: "requested").user }
  let(:resource_url) { resource_locator(resource).url }
  let(:email_subject) { "#{author_nickname} rejected your application to the promoter committee" }
  let(:email_intro) { "#{author_nickname} rejected your application to be part of the promoter committee for the following initiative #{resource_title}." }
  let(:email_outro) { "You received this notification because you applied to this initiative: #{resource_title}." }
  let(:notification_title) { "<a href=\"#{author_profile_url}\">#{author_nickname}</a> rejected your application to be part of the promoter committee for the following initiative <a href=\"#{resource_url}\">#{resource_title}</a>." }

  it_behaves_like "a simple event email"
  it_behaves_like "a simple event notification"

  describe "types" do
    subject { described_class }

    it "supports notifications" do
      expect(subject.types).to include :notification
    end

    it "supports emails" do
      expect(subject.types).to include :email
    end
  end
end
