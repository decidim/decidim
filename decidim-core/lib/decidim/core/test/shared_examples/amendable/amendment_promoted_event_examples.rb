# frozen_string_literal: true

shared_examples "amendment promoted event" do
  include_context "when a simple event"

  let(:resource) { emendation }
  let(:event_name) { "decidim.events.amendments.amendment_promoted" }

  it_behaves_like "a simple event"

  let(:amendable_title) { amendable.title }
  let(:emendation_author_nickname) { "@#{emendation.creator_author.nickname}" }
  let(:emendation_path) { Decidim::ResourceLocatorPresenter.new(emendation).path }
  let(:emendation_author_path) { Decidim::UserPresenter.new(emendation.creator_author).profile_path }
  let(:amendable_path) { Decidim::ResourceLocatorPresenter.new(amendable).path }

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("An emendation from #{emendation_author_nickname} has been promoted")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro)
        .to eq("An emendation rejected for #{amendable_title} has been promoted to an independent #{amendable_type}. You can see it from this page:")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to eq("You have received this notification because you are following #{amendable_title}. You can stop receiving notifications following the previous link.")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to include("A <a href=\"#{emendation_path}\">rejected emendation</a> for <a href=\"#{amendable_path}\">#{amendable_title}</a> #{amendable_type} has been promoted by <a href=\"#{emendation_author_path}\">#{emendation_author_nickname}</a>.") # rubocop:disable Metrics/LineLength
    end
  end
end
