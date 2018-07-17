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
    end
  end
end
