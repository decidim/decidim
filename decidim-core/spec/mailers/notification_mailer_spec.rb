# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe NotificationMailer, type: :mailer do
    let(:organization) { create(:organization, name: "O'Connor") }
    let(:user) { create(:user, name: "Sarah Connor", organization:) }
    let(:resource) { user }
    let(:event_class_name) { "Decidim::ProfileUpdatedEvent" }
    let(:extra) { { foo: "bar" } }
    let(:event) { "decidim.events.users.profile_updated" }
    let(:event_instance) do
      event_class_name.constantize.new(resource:, event_name: event, user:, user_role: :follower, extra:)
    end

    describe "event_received" do
      let(:mail) { described_class.event_received(event, event_class_name, resource, user, :follower, extra) }

      it "gets the subject from the event" do
        expect(mail.subject).to include("updated their profile")
      end

      it "delivers the email to the user" do
        expect(mail.to).to eq([user.email])
      end

      it "includes the organization data" do
        expect(mail.body.encoded).to include(user.organization.name)
      end

      it "includes the greeting" do
        expect(mail.body).to include(event_instance.email_greeting)
      end

      it "includes the intro" do
        expect(mail.body).to include(event_instance.email_intro)
      end

      it "includes the outro" do
        expect(mail.body).to include(event_instance.email_outro)
      end

      it "includes the resource url" do
        expect(mail.body).to include(event_instance.resource_url)
      end

      context "when the user doesn't have an email" do
        let(:user) { create(:user, :deleted) }

        it "does nothing" do
          expect(mail.deliver_now).to be_nil
        end
      end

      include_examples "email with logo"

      context "when the event defines buttons" do
        class Decidim::ProfileUpdatedEvent
          def button_text
            "BUTTON TEXT"
          end

          def button_url
            "http://button.link"
          end
        end

        it "includes the button text" do
          expect(mail.body).to include(event_instance.button_text)
        end

        it "includes the button url" do
          expect(mail.body).to include(event_instance.button_url)
        end
      end
    end
  end
end
