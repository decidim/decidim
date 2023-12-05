# frozen_string_literal: true

require "spec_helper"

describe Decidim::Initiatives::EndorseInitiativeEvent do
  include Decidim::TranslationsHelper
  include Decidim::SanitizeHelper

  subject do
    described_class.new(resource: initiative, event_name:, user:, extra: {})
  end

  let(:organization) { initiative.organization }
  let(:initiative) { create(:initiative) }
  let(:initiative_author) { initiative.author }
  let(:event_name) { "decidim.events.initiatives.initiative_endorsed" }
  let(:user) { create(:user, organization:) }
  let(:resource_path) { resource_locator(initiative).path }
  let(:email_subject) { "Initiative endorsed by @#{initiative_author.nickname}" }
  let(:email_intro) { "#{initiative_author.name} @#{initiative_author.nickname}, who you are following, has endorsed the following initiative, maybe you want to contribute to the conversation:" }
  let(:email_outro) { "You have received this notification because you are following @#{initiative_author.nickname}. You can stop receiving notifications following the previous link." }
  let(:intiative_title) { decidim_html_escape(translated(initiative.title)) }
  let(:notification_title) { <<-EOTITLE.squish }
    The <a href=\"#{resource_path}\">#{intiative_title}</a> initiative was endorsed by
    <a href=\"/profiles/#{initiative_author.nickname}\">#{initiative_author.name} @#{initiative_author.nickname}</a>.
    EOTITLE

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
