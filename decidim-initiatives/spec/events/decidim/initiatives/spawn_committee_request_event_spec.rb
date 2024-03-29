# frozen_string_literal: true

require "spec_helper"

describe Decidim::Initiatives::SpawnCommitteeRequestEvent do
  include_context "when a simple event"

  let(:user_role) { :affected_user }
  let(:extra) { { applicant: } }
  let(:user) { resource.author }
  let(:organization) { resource.organization }
  let(:resource) { create(:initiative) }
  let(:event_name) { "decidim.events.initiatives.initiative_created" }
  let(:applicant) { create(:user, organization:) }
  let(:applicant_profile_url) { Decidim::UserPresenter.new(applicant).profile_url }
  let(:applicant_nickname) { Decidim::UserPresenter.new(applicant).nickname }
  let(:resource_url) { resource_locator(resource).url }
  let(:email_subject) { "#{applicant_nickname} wants to join your initiative" }
  let(:email_intro) { "#{applicant_nickname} applied for the promoter committee of your initiative #{resource_title}. To accept or reject the application, go to the edit form of your initiative." }
  let(:email_outro) { "You received this notification because you are the author of this initiative: #{resource_title}" }
  let(:notification_title) { "<a href=\"#{applicant_profile_url}\">#{applicant_nickname}</a> applied for the promoter committee of your initiative <a href=\"#{resource_url}\">#{resource_title}</a>. To accept or reject click <a href=\"#{resource_url}/edit\">here</a>." }

  describe "types" do
    subject { described_class }

    it "supports notifications" do
      expect(subject.types).to include :notification
    end

    it "supports emails" do
      expect(subject.types).to include :email
    end
  end

  it_behaves_like "a simple event email"
  it_behaves_like "a simple event notification"
end
