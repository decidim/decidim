# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe Admin::UpdateConference do
    describe "call" do
      let(:my_conference) { create :conference }
      let(:user) { create :user, :admin, :confirmed, organization: my_conference.organization }

      let(:params) do
        {
          conference: {
            id: my_conference.id,
            title_en: "Foo title",
            title_ca: "Foo title",
            title_es: "Foo title",
            slogan_en: my_conference.slogan,
            slogan_ca: my_conference.slogan,
            slogan_es: my_conference.slogan,
            location: my_conference.location,
            slug: my_conference.slug,
            hashtag: my_conference.hashtag,
            hero_image: nil,
            banner_image: nil,
            promoted: my_conference.promoted,
            description_en: my_conference.description,
            description_ca: my_conference.description,
            description_es: my_conference.description,
            short_description_en: my_conference.short_description,
            short_description_ca: my_conference.short_description,
            short_description_es: my_conference.short_description,
            current_organization: my_conference.organization,
            scopes_enabled: my_conference.scopes_enabled,
            scope: my_conference.scope,
            objectives: my_conference.objectives,
            start_date: my_conference.start_date,
            end_date: my_conference.end_date,
            errors: my_conference.errors,
            show_statistics: my_conference.show_statistics,
            registrations_enabled: my_conference.registrations_enabled,
            available_slots: my_conference.available_slots,
            registration_terms: my_conference.registration_terms
          }
        }
      end
      let(:context) do
        {
          current_organization: my_conference.organization,
          current_user: user,
          conference_id: my_conference.id
        }
      end
      let(:form) do
        Admin::ConferenceForm.from_params(params).with_context(context)
      end
      let(:command) { described_class.new(my_conference, form) }

      describe "when the form is not valid" do
        before do
          expect(form).to receive(:invalid?).and_return(true)
        end

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end

        it "doesn't update the conference" do
          command.call
          my_conference.reload

          expect(my_conference.title["en"]).not_to eq("Foo title")
        end
      end

      describe "when the conference is not valid" do
        before do
          expect(form).to receive(:invalid?).and_return(false)
          expect(my_conference).to receive(:valid?).at_least(:once).and_return(false)
          my_conference.errors.add(:hero_image, "Image too big")
          my_conference.errors.add(:banner_image, "Image too big")
        end

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end

        it "adds errors to the form" do
          command.call

          expect(form.errors[:hero_image]).not_to be_empty
          expect(form.errors[:banner_image]).not_to be_empty
        end
      end

      describe "when the form is valid" do
        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "updates the conference" do
          expect { command.call }.to broadcast(:ok)
          my_conference.reload

          expect(my_conference.title["en"]).to eq("Foo title")
        end

        it "traces the action", versioning: true do
          expect(Decidim.traceability)
            .to receive(:perform_action!)
            .with(:update, my_conference, user)
            .and_call_original

          expect { command.call }.to change(Decidim::ActionLog, :count)
          action_log = Decidim::ActionLog.last
          expect(action_log.version).to be_present
        end

        context "when no homepage image is set" do
          it "does not replace the homepage image" do
            command.call
            my_conference.reload

            expect(my_conference.hero_image).to be_present
          end
        end

        context "when no banner image is set" do
          it "does not replace the banner image" do
            command.call
            my_conference.reload

            expect(my_conference.banner_image).to be_present
          end
        end
      end

      describe "events" do
        let!(:follow) { create :follow, followable: my_conference, user: user }
        let(:title) { my_conference.title }
        let(:start_date) { my_conference.start_date }
        let(:end_date) { my_conference.end_date }
        let(:location) { my_conference.location }
        let(:form) do
          double(
            invalid?: false,
            title: title,
            slogan: my_conference.slogan,
            slug: my_conference.slug,
            hashtag: my_conference.slug,
            short_description: my_conference.short_description,
            description: my_conference.description,
            objectives: my_conference.objectives,
            location: location,
            start_date: start_date,
            end_date: end_date,
            scopes_enabled: my_conference.scopes_enabled,
            scope: my_conference.scope,
            hero_image: nil,
            banner_image: nil,
            promoted: my_conference.promoted,
            show_statistics: my_conference.show_statistics,
            registrations_enabled: my_conference.registrations_enabled,
            available_slots: my_conference.available_slots,
            registration_terms: my_conference.registration_terms,
            current_organization: my_conference.organization,
            current_user: user
          )
        end

        context "when nothing changes" do
          it "doesn't notify the change" do
            expect(Decidim::EventsManager)
              .not_to receive(:publish)

            command.call
          end
        end

        context "when a non-important attribute changes" do
          let(:title) do
            {
              "en" => "Title updated"
            }
          end

          it "doesn't notify the change" do
            expect(Decidim::EventsManager)
              .not_to receive(:publish)

            command.call
          end

          it "doesn't schedule the upcoming conference notification job" do
            expect(UpcomingConferenceNotificationJob)
              .not_to receive(:perform_later)

            command.call
          end
        end

        context "when the start date changes" do
          let(:start_date) { my_conference.start_date - 1.day }

          it "notifies the change" do
            expect(Decidim::EventsManager)
              .to receive(:publish)
              .with(
                event: "decidim.events.conferences.conference_updated",
                event_class: UpdateConferenceEvent,
                resource: my_conference,
                recipient_ids: [user.id]
              )

            command.call
          end

          it "schedules a upcoming conference notification job 48h before start time" do
            expect(UpcomingConferenceNotificationJob)
              .to receive(:generate_checksum).and_return "1234"

            expect(UpcomingConferenceNotificationJob)
              .to receive_message_chain(:set, :perform_later) # rubocop:disable RSpec/MessageChain
              .with(set: start_date - 2.days).with(my_conference.id, "1234")

            command.call
          end
        end

        context "when the end date changes" do
          let(:end_date) { my_conference.end_date + 1.day }

          it "notifies the change" do
            expect(Decidim::EventsManager)
              .to receive(:publish)
              .with(
                event: "decidim.events.conferences.conference_updated",
                event_class: UpdateConferenceEvent,
                resource: my_conference,
                recipient_ids: [user.id]
              )

            command.call
          end
        end

        context "when the location changes" do
          let(:location) { "some location" }

          it "notifies the change" do
            expect(Decidim::EventsManager)
              .to receive(:publish)
              .with(
                event: "decidim.events.conferences.conference_updated",
                event_class: UpdateConferenceEvent,
                resource: my_conference,
                recipient_ids: [user.id]
              )

            command.call
          end
        end
      end
    end
  end
end
