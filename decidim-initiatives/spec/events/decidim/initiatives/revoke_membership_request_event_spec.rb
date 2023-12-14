# frozen_string_literal: true

require "spec_helper"

describe Decidim::Initiatives::RevokeMembershipRequestEvent do
  subject do
    described_class.new(
      resource: initiative,
      event_name:,
      user: [membership_request.user],
      user_role: :affected_user,
      extra: { author: }
    )
  end

  let(:event_name) { "decidim.events.initiatives.approve_membership_request" }
  let(:organization) { create(:organization) }
  let!(:initiative) { create(:initiative, :created, organization:) }
  let(:author) { initiative.author }
  let(:author_profile_url) { Decidim::UserPresenter.new(author).profile_url }
  let(:author_nickname) { Decidim::UserPresenter.new(author).nickname }
  let(:membership_request) { create(:initiatives_committee_member, initiative:, state: "requested") }
  let(:resource_url) { resource_locator(initiative).url }
  let(:resource_title) { translated(initiative.title) }
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
