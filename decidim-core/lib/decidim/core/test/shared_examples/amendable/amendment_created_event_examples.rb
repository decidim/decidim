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
  it_behaves_like "a simple event email"
  it_behaves_like "a simple event notification"

  let(:emendation_author_nickname) { "@#{emendation.creator_author.nickname}" }
  let(:emendation_path) { Decidim::ResourceLocatorPresenter.new(emendation).path }
  let(:emendation_author_path) { Decidim::UserPresenter.new(emendation.creator_author).profile_path }
  let(:amendable_path) { Decidim::ResourceLocatorPresenter.new(amendable).path }

  let(:email_subject) { "New amendment for #{amendable_title}" }
  let(:email_intro) { "A new amendment has been created for #{amendable_title}. You can see it from this page:" }
  let(:email_outro) { "You have received this notification because you are following #{amendable_title}. You can stop receiving notifications following the previous link." }
  let(:notification_title) { "A new amendment has been created for <a href=\"#{amendable_path}\">#{amendable_title}</a>." }
end
