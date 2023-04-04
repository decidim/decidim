# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Debates
    describe CreationDisabledEvent do
      include Decidim::ComponentPathHelper

      include_context "when a simple event"

      let(:event_name) { "decidim.events.debates.creation_disabled" }
      let(:resource) { create(:debates_component) }
      let(:participatory_space) { resource.participatory_space }
      let(:resource_path) { main_component_path(resource) }

      it_behaves_like "a simple event"

      describe "email_subject" do
        it "is generated correctly" do
          expect(subject.email_subject).to eq("Debate creation disabled in #{participatory_space_title}")
        end
      end

      describe "email_intro" do
        it "is generated correctly" do
          expect(subject.email_intro)
            .to eq("Debate creation is no longer active in #{participatory_space_title}. You can still participate in open debates from this page:")
        end
      end

      describe "email_outro" do
        it "is generated correctly" do
          expect(subject.email_outro)
            .to include("You have received this notification because you are following #{participatory_space_title}")
        end
      end

      describe "notification_title" do
        it "is generated correctly" do
          expect(subject.notification_title)
            .to eq("Debate creation is now disabled in <a href=\"#{participatory_space_url}\">#{participatory_space_title}</a>")
        end
      end

      describe "debate disabled event" do
        let!(:component) { create(:debates_component, organization:, participatory_space:) }
        let(:user) { create(:user, :confirmed, :admin, organization:, notifications_sending_frequency: "daily", locale: "en") }
        let!(:record) do
          create(
            :debate,
            component:,
            title: { en: "Event notifier" },
            description: { en: "This debate is for testing purposes" },
            instructions: { en: "Use this debate for testing" }
          )
        end

        let(:params) do
          {
            conclusions: "testi testi",
            id: record.id
          }
        end

        let(:form) { Decidim::Debates::Admin::CloseDebateForm.from_params(params).with_context(current_user: user) }

        let!(:command) { Decidim::Debates::Admin::CloseDebate.new(form) }

        it_behaves_like "event notification"
      end
    end
  end
end
