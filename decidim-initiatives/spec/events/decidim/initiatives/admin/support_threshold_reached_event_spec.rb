# frozen_string_literal: true

require "spec_helper"

describe Decidim::Initiatives::Admin::SupportThresholdReachedEvent do
  include_context "when a simple event"

  let(:event_name) { "decidim.events.initiatives.support_threshold_reached" }
  let(:resource) { initiative }

  let(:initiative) { create(:initiative) }
  let(:participatory_space) { initiative }
  let(:initiative_title) { decidim_html_escape(translated(initiative.title)) }
  let(:email_subject) { "Signatures threshold reached" }
  let(:email_intro) { "The initiative #{initiative_title} has reached the signatures threshold" }
  let(:email_outro) { "You have received this notification because you are an admin of the platform." }
  let(:notification_title) { "The <a href=\"#{resource_path}\">#{initiative_title}</a> initiative has reached the signatures threshold" }

  it_behaves_like "a simple event"
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
