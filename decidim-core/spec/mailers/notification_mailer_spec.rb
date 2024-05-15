# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe NotificationMailer do
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

      context "when the user does not have an email" do
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

      context "when the event has a linked resource" do
        shared_examples "amendment notification mails" do
          let!(:amendment) { create(:amendment, amendable:, emendation:) }
          let(:component) { create(:proposal_component) }
          let(:amendable) { create(:proposal, component:) }
          let(:emendation) { create(:proposal, component:, title: %(Testing <a href="https://example.org">proposal</a>)) }
          let(:link_to_emendation) { ::Decidim::ResourceLocatorPresenter.new(emendation).url }
          let(:resource) { emendation }

          it "includes the link to the resource" do
            expect(mail.body).to include(
              %(<a href="#{link_to_emendation}">Testing proposal</a>)
            )
          end
        end

        context "when the amendment is created" do
          let(:event_class_name) { "Decidim::Amendable::AmendmentCreatedEvent" }
          let(:event) { "decidim.events.amendments.amendment_created" }

          it_behaves_like "amendment notification mails"
        end

        context "when the amendment is accepted" do
          let(:event_class_name) { "Decidim::Amendable::AmendmentAcceptedEvent" }
          let(:event) { "decidim.events.amendments.amendment_accepted" }

          it_behaves_like "amendment notification mails"
        end

        context "when the amendment is rejected" do
          let(:event_class_name) { "Decidim::Amendable::AmendmentRejectedEvent" }
          let(:event) { "decidim.events.amendments.amendment_rejected" }

          it_behaves_like "amendment notification mails"
        end

        context "when the emendation is promoted" do
          let(:event_class_name) { "Decidim::Amendable::EmendationPromotedEvent" }
          let(:event) { "decidim.events.amendments.emendation_promoted" }

          it_behaves_like "amendment notification mails"
        end
      end
    end
  end
end
