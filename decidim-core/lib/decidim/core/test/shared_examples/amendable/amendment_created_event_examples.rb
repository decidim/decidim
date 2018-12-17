# frozen_string_literal: true

shared_examples "amendment created event" do
  include_context "when a simple event"

  let(:resource) { amendable }
  let(:event_name) { "decidim.events.amendments.amendment_created" }
  let!(:extra) do
    {
      amendment_id: amendment.id
    }
  end

  it_behaves_like "a simple event"

  let(:amendable_title) { amendable.title }
  let(:emendation_author_nickname) { "@#{emendation.creator_author.nickname}" }
  let(:emendation_path) { Decidim::ResourceLocatorPresenter.new(emendation).path }
  let(:emendation_author_path) { Decidim::UserPresenter.new(emendation.creator_author).profile_path }
  let(:amendable_path) { Decidim::ResourceLocatorPresenter.new(amendable).path }

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("A new amendment for #{amendable_title} from #{emendation_author_nickname}")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro)
        .to eq("A new emendation has been created for #{amendable_title}. You can see it from this page:")
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
        .to include("A <a href=\"#{emendation_path}\">new emendation</a> has been created by <a href=\"#{emendation_author_path}\">#{emendation_author_nickname}</a> for <a href=\"#{amendable_path}\">#{amendable_title}</a> #{amendable_type}.") # rubocop:disable Metrics/LineLength
    end
  end
end
