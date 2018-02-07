# frozen_string_literal: true

require "spec_helper"

describe Decidim::Debates::CreateDebateEvent do
  include_context "simple event"

  let(:resource) { create :debate, :with_author }
  let(:space) { resource.participatory_space }
  let(:event_name) { "decidim.events.debates.debate_created" }
  let(:space_path) { resource_locator(space).path }
  let(:extra) { { type: type.to_s } }

  context "when the notification is for user followers" do
    let(:type) { :user }

    it_behaves_like "a simple event"

    describe "email_subject" do
      it "is generated correctly" do
        expect(subject.email_subject).to eq("New debate by @#{author.nickname}")
      end
    end

    describe "email_intro" do
      it "is generated correctly" do
        expect(subject.email_intro)
          .to eq("Hi,\n#{author.name} @#{author.nickname}, who you are following, has created a new debate, check it out and contribute:")
      end
    end

    describe "email_outro" do
      it "is generated correctly" do
        expect(subject.email_outro)
          .to eq("You have received this notification because you are following @#{author.nickname}. You can stop receiving notifications following the previous link.")
      end
    end

    describe "notification_title" do
      it "is generated correctly" do
        expect(subject.notification_title)
          .to include("The <a href=\"#{resource_path}\">#{resource_title}</a> debate was created by ")

        expect(subject.notification_title)
          .to include("<a href=\"/profiles/#{author.nickname}\">#{author.name} @#{author.nickname}</a>.")
      end
    end
  end

  context "when the notification is for space followers" do
    let(:type) { :space }

    it_behaves_like "a simple event"

    describe "email_subject" do
      it "is generated correctly" do
        expect(subject.email_subject).to eq("New debate on #{translated(space.title)}")
      end
    end

    describe "email_intro" do
      it "is generated correctly" do
        expect(subject.email_intro)
          .to eq("Hi,\nA new debate has been created on the #{translated(space.title)} participatory space, check it out and contribute:")
      end
    end

    describe "email_outro" do
      it "is generated correctly" do
        expect(subject.email_outro)
          .to eq("You have received this notification because you are following the #{translated(space.title)} participatory space. " \
          "You can stop receiving notifications following the previous link.")
      end
    end

    describe "notification_title" do
      it "is generated correctly" do
        expect(subject.notification_title)
          .to include("The <a href=\"#{resource_path}\">#{resource_title}</a> debate was created on ")

        expect(subject.notification_title)
          .to include("<a href=\"#{space_path}\">#{translated(space.title)}</a>.")
      end
    end
  end
end
