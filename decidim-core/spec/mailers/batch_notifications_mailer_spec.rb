# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe BatchNotificationsMailer, type: :mailer do
    include ActionView::Helpers::DateHelper

    let(:organization) { create(:organization, name: "O'Connor") }
    let(:user) { create(:user, name: "Sarah Connor", organization: organization) }
    let(:notifications) { create_list(:notification, 3, user: user) }
    let(:events) { events_serializer(notifications) }
    let(:see_more) { "You have received a lot of notifications on <a href='http://#{organization.host}/'>#{organization.name}</a>. Go check them out on your <a href='/notifications'>notifications</a> space" }

    describe "#event_received" do
      let(:mail) { described_class.event_received(events, user) }

      it "gets the subject from the event" do
        expect(mail.subject).to include("You have received notifications on #{organization.name}")
      end

      it "delivers the email to the user" do
        expect(mail.to).to include(user.email)
      end

      it "includes the organization data" do
        expect(mail.body.encoded).to include(organization.name)
      end

      it "includes the greeting" do
        expect(mail.body).to include("Greetings #{user.nickname}")
      end

      it "includes the intro" do
        expect(mail.body).to include("You are receiving this email because you have subscribed to resources on #{organization.name}")
      end

      it "includes the outro" do
        expect(mail.body).to include("You can stop receiving notifications by visiting your <a href='/profiles/#{user.nickname}'>profile</a>")
      end

      it "doesn't includes see more" do
        expect(mail.body).not_to include(see_more)
      end

      it "includes events elements" do
        expect(events.count).to eq(3)

        events.each do |event|
          expect(mail.body).to include(event_instance(event).notification_title)
        end
      end

      context "when the user doesn't have an email" do
        let(:user) { create(:user, :deleted) }

        it "does nothing" do
          expect(mail.deliver_now).to be_nil
        end
      end

      context "when there is more email than batch_email_notifications_max_length" do
        before do
          allow(Decidim.config).to receive(:batch_email_notifications_max_length).and_return(1)
        end

        it "displays see more link" do
          expect(mail.body).to include(see_more)
        end

        it "displays only one event" do
          expect(events.count).to eq(3)

          expect(mail.body).to include(event_instance(events.first).notification_title)

          events.drop(1).each do |event|
            expect(mail.body).not_to include(event_instance(event).notification_title)
          end
        end
      end
    end

    private

    def events_serializer(events)
      events.map do |event|
        {
          resource: event.resource,
          event_class: event.event_class,
          event_name: event.event_name,
          user: event.user,
          extra: event.extra,
          user_role: event.user_role,
          created_at: time_ago_in_words(event.created_at).capitalize
        }
      end
    end

    def event_instance(event)
      event[:event_class].constantize.new(
        resource: event[:resource],
        event_name: event[:event_name],
        user: event[:user],
        extra: event[:extra],
        user_role: event[:user_role]
      )
    end
  end
end
