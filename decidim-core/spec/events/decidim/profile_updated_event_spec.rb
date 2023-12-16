# frozen_string_literal: true

require "spec_helper"

describe Decidim::ProfileUpdatedEvent do
  include_context "when a simple event"

  let(:event_name) { "decidim.events.users.profile_updated" }
  let(:resource) { create(:user) }
  let(:author) { resource }
  let(:email_subject) { "@#{resource.nickname} updated their profile" }
  let(:email_intro) { "The <a href=\"#{author_presenter.profile_url}\">profile page</a> of #{resource.name} (@#{resource.nickname}), who you are following, has been updated." }
  let(:email_outro) { "You have received this notification because you are following @#{resource.nickname}. You can stop receiving notifications following the previous link." }
  let(:notification_title) { "The <a href=\"#{author_presenter.profile_path}\">profile page</a> of #{resource.name} (@#{resource.nickname}), who you are following, has been updated." }

  it_behaves_like "a simple event", true
  it_behaves_like "a simple event email"
  it_behaves_like "a simple event notification"

  # describe "email_subject" do
  #   it "is generated correctly" do
  #     expect(subject.email_subject).to eq("@#{resource.nickname} updated their profile")
  #   end
  # end

  # describe "email_intro" do
  #   it "is generated correctly" do
  #     expect(subject.email_intro)
  #       .to eq("The <a href=\"#{author_presenter.profile_url}\">profile page</a> of #{resource.name} (@#{resource.nickname}), who you are following, has been updated.")
  #   end
  # end

  # describe "email_outro" do
  #   it "is generated correctly" do
  #     expect(subject.email_outro)
  #       .to eq("You have received this notification because you are following @#{resource.nickname}. You can stop receiving notifications following the previous link.")
  #   end
  # end

  # describe "notification_title" do
  #   it "is generated correctly" do
  #     expect(subject.notification_title).to include("<a href=\"#{author_presenter.profile_path}\">profile page</a>")
  #   end
  # end
end
