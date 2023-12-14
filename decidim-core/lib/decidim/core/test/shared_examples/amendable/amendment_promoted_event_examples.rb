# frozen_string_literal: true

shared_examples "amendment promoted event" do
  include_context "when a simple event"

  let(:resource) { emendation }
  let(:event_name) { "decidim.events.amendments.amendment_promoted" }

  it_behaves_like "a simple event"
  it_behaves_like "a simple event email"
  it_behaves_like "a simple event notification"

  let(:emendation_author_nickname) { "@#{emendation.creator_author.nickname}" }
  let(:emendation_path) { Decidim::ResourceLocatorPresenter.new(emendation).path }
  let(:emendation_author_path) { Decidim::UserPresenter.new(emendation.creator_author).profile_path }
  let(:amendable_path) { Decidim::ResourceLocatorPresenter.new(amendable).path }

  let(:email_subject) { "An amendment from #{emendation_author_nickname} has been published as a new proposal" }
  let(:email_intro) { "A rejected amendment for #{amendable_title} has been published as a new #{amendable_type}. You can see it from this page:" }
  let(:email_outro) { "You have received this notification because you are following #{amendable_title}. You can stop receiving notifications following the previous link." }
  # rubocop:disable Layout/LineLength
  let(:notification_title) { "A <a href=\"#{emendation_path}\">rejected amendment</a> for <a href=\"#{amendable_path}\">#{amendable_title}</a> has been published as a new #{amendable_type} by <a href=\"#{emendation_author_path}\">#{emendation_author_nickname}</a>." }
  # rubocop:enable Layout/LineLength
end
