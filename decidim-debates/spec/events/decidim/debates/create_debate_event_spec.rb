# frozen_string_literal: true

require "spec_helper"

describe Decidim::Debates::CreateDebateEvent do
  subject do
    described_class.new(resource: debate, event_name: event_name, user: user, extra: { type: type.to_s })
  end

  let(:organization) { debate.organization }
  let(:debate) { create :debate, :with_author }
  let(:space) { debate.participatory_space }
  let(:debate_author) { debate.author }
  let(:event_name) { "decidim.events.debates.debate_created" }
  let(:user) { create :user, organization: organization }
  let(:resource_path) { resource_locator(debate).path }
  let(:space_path) { resource_locator(space).path }

  describe "notification types" do
    subject { described_class }

    it "supports notifications" do
      expect(subject.types).to include :notification
    end

    it "supports emails" do
      expect(subject.types).to include :email
    end
  end

  context "when the notification is for user followers" do
    let(:type) { :user }

    describe "email_subject" do
      it "is generated correctly" do
        expect(subject.email_subject).to eq("New debate by @#{debate_author.nickname}")
      end
    end

    describe "email_intro" do
      it "is generated correctly" do
        expect(subject.email_intro)
          .to eq("Hi,\n#{debate_author.name} @#{debate_author.nickname}, who you are following, has created a new debate, check it out and contribute:")
      end
    end

    describe "email_outro" do
      it "is generated correctly" do
        expect(subject.email_outro)
          .to eq("You have received this notification because you are following @#{debate_author.nickname}. You can stop receiving notifications following the previous link.")
      end
    end

    describe "notification_title" do
      it "is generated correctly" do
        expect(subject.notification_title)
          .to include("The <a href=\"#{resource_path}\">#{debate.title["en"]}</a> debate was created by ")

        expect(subject.notification_title)
          .to include("<a href=\"/profiles/#{debate_author.nickname}\">#{debate_author.name} @#{debate_author.nickname}</a>.")
      end
    end
  end

  context "when the notification is for space followers" do
    let(:type) { :space }

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
          .to include("The <a href=\"#{resource_path}\">#{debate.title["en"]}</a> debate was created on ")

        expect(subject.notification_title)
          .to include("<a href=\"#{space_path}\">#{translated(space.title)}</a>.")
      end
    end
  end
end
