# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe Admin::UpdateConference do
    describe "call" do
      let(:organization) { create(:organization) }
      let(:my_conference) { create(:conference, taxonomies:, organization:) }
      let(:taxonomies) { create_list(:taxonomy, 2, :with_parent, organization:) }
      let(:taxonomy) { create(:taxonomy, :with_parent, organization:) }
      let(:user) { create(:user, :admin, :confirmed, organization:) }
      let!(:participatory_processes) do
        create_list(
          :participatory_process,
          3,
          organization:
        )
      end
      let!(:assemblies) do
        create_list(
          :assembly,
          3,
          organization:
        )
      end

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
            weight: my_conference.weight,
            slug: my_conference.slug,
            promoted: my_conference.promoted,
            description_en: my_conference.description,
            description_ca: my_conference.description,
            description_es: my_conference.description,
            short_description_en: my_conference.short_description,
            short_description_ca: my_conference.short_description,
            short_description_es: my_conference.short_description,
            current_organization: organization,
            objectives: my_conference.objectives,
            start_date: my_conference.start_date,
            end_date: my_conference.end_date,
            errors: my_conference.errors,
            taxonomies: [taxonomy.id, taxonomies.first.id],
            show_statistics: my_conference.show_statistics,
            registrations_enabled: my_conference.registrations_enabled,
            available_slots: my_conference.available_slots,
            registration_terms: my_conference.registration_terms,
            participatory_processes_ids: participatory_processes.map(&:id),
            assemblies_ids: assemblies.map(&:id)
          }.merge(attachments_params)
        }
      end
      let(:attachments_params) do
        {
          hero_image: my_conference.hero_image.blob,
          banner_image: my_conference.banner_image.blob
        }
      end
      let(:context) do
        {
          current_organization: organization,
          current_user: user,
          conference_id: my_conference.id
        }
      end
      let(:form) do
        Admin::ConferenceForm.from_params(params).with_context(context)
      end
      let(:command) { described_class.new(form, my_conference) }

      describe "when the form is not valid" do
        before do
          allow(form).to receive(:invalid?).and_return(true)
        end

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end

        it "does not update the conference" do
          command.call
          my_conference.reload

          expect(my_conference.title["en"]).not_to eq("Foo title")
        end
      end

      describe "when the conference is not valid" do
        before do
          allow(form).to receive(:invalid?).and_return(false)
          expect(my_conference).to receive(:valid?).at_least(:once).and_return(false)
          my_conference.errors.add(:hero_image, "File resolution is too large")
          my_conference.errors.add(:banner_image, "File resolution is too large")
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

        it "updates the taxonomies" do
          expect(my_conference.reload.taxonomies).to match_array(taxonomies)
          command.call
          expect(my_conference.reload.taxonomies).to contain_exactly(taxonomy, taxonomies.first)
        end

        it "updates the conference" do
          expect { command.call }.to broadcast(:ok)
          my_conference.reload

          expect(my_conference.title["en"]).to eq("Foo title")
        end

        it "traces the action", versioning: true do
          expect(Decidim.traceability)
            .to receive(:perform_action!)
            .with(:update, my_conference, user, {})
            .and_call_original

          expect { command.call }.to change(Decidim::ActionLog, :count)
          action_log = Decidim::ActionLog.last
          expect(action_log.version).to be_present
        end

        it "links participatory processes" do
          command.call
          linked_participatory_processes = my_conference.linked_participatory_space_resources(:participatory_processes, "included_participatory_processes")
          expect(linked_participatory_processes).to match_array(participatory_processes)
        end

        it "links assemblies" do
          command.call
          linked_assemblies = my_conference.linked_participatory_space_resources(:assemblies, "included_assemblies")
          expect(linked_assemblies).to match_array(assemblies)
        end

        context "when homepage image is not updated" do
          let(:attachments_params) do
            {
              banner_image: my_conference.banner_image.blob
            }
          end

          it "does not replace the homepage image" do
            expect(my_conference).not_to receive(:hero_image=)

            command.call
            my_conference.reload

            expect(my_conference.hero_image).to be_present
          end
        end

        context "when banner image is not updated" do
          let(:attachments_params) do
            {
              hero_image: my_conference.hero_image.blob
            }
          end

          it "does not replace the banner image" do
            expect(my_conference).not_to receive(:banner_image=)

            command.call
            my_conference.reload

            expect(my_conference.banner_image).to be_present
          end
        end
      end

      describe "events" do
        let!(:follow) { create(:follow, followable: my_conference, user:) }
        let(:title) { my_conference.title }
        let(:start_date) { my_conference.start_date }
        let(:end_date) { my_conference.end_date }
        let(:location) { my_conference.location }
        let(:form) do
          double(
            invalid?: false,
            title:,
            slogan: my_conference.slogan,
            weight: my_conference.weight,
            slug: my_conference.slug,
            short_description: my_conference.short_description,
            description: my_conference.description,
            objectives: my_conference.objectives,
            location:,
            start_date:,
            end_date:,
            hero_image: nil,
            remove_hero_image: false,
            banner_image: nil,
            remove_banner_image: false,
            taxonomizations: [],
            promoted: my_conference.promoted,
            show_statistics: my_conference.show_statistics,
            registrations_enabled: my_conference.registrations_enabled,
            available_slots: my_conference.available_slots,
            registration_terms: my_conference.registration_terms,
            current_organization: organization,
            current_user: user,
            participatory_processes_ids: participatory_processes.map(&:id),
            assemblies_ids: assemblies.map(&:id)
          )
        end

        context "when nothing changes" do
          it "does not notify the change" do
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

          it "does not notify the change" do
            expect(Decidim::EventsManager)
              .not_to receive(:publish)

            command.call
          end

          it "does not schedule the upcoming conference notification job" do
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
                followers: [user]
              )

            command.call
          end

          it "schedules a upcoming conference notification job 48h before start time" do
            allow(UpcomingConferenceNotificationJob)
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
                followers: [user]
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
                followers: [user]
              )

            command.call
          end
        end
      end
    end
  end
end
