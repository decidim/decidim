# frozen_string_literal: true

require "spec_helper"

describe "Meeting live event access", type: :system do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let!(:user) { create :user, :confirmed, organization: organization }
  let(:meeting_live_event_path) do
    decidim_participatory_process_meetings.meeting_live_event_path(
      participatory_process_slug: participatory_process.slug,
      component_id: component.id,
      meeting_id: meeting.id
    )
  end

  def visit_meeting
    visit resource_locator(meeting).path
  end

  context "when online meeting is live" do
    let(:meeting) { create :meeting, :published, :online, :live, component: component }

    it "shows the link to the live meeting streaming" do
      visit_meeting

      expect(page).to have_content("This meeting is happening right now")
    end

    context "when the meeting is configured to not embed the iframe" do
      let(:meeting) { create :meeting, :published, :online, :live, :embeddable, component: component }

      it "shows the link to the live meeting streaming" do
        visit_meeting

        new_window = window_opened_by { click_link "Join meeting" }

        within_window new_window do
          expect(page).to have_current_path(meeting_live_event_path)
        end
      end
    end

    context "when the meeting is configured to not embed the iframe and is not embeddable" do
      let(:meeting) { create :meeting, :published, :online, :live, component: component }

      it "shows the link to the external streaming service" do
        visit_meeting

        # Join the meeting displays a warning to users because
        # is redirecting to a different domain
        click_link "Join meeting"

        expect(page).to have_content("Open external link")
      end
    end

    context "when the meeting is configured to show the iframe embedded" do
      let(:meeting) { create :meeting, :published, :embed_in_meeting_page_iframe_embed_type, :online, :embeddable, :live, component: component }

      it "shows the meeting link embedded" do
        visit_meeting

        expect(page).to have_css("iframe")
      end

      context "and the iframe access level is for all visitors" do
        let(:meeting) { create :meeting, :published, :embed_in_meeting_page_iframe_embed_type, :online, :embeddable, :live, component: component }

        context "and user is signed in" do
          before do
            login_as user, scope: :user
          end

          it "shows the meeting link embedded" do
            visit_meeting

            expect(page).to have_css("iframe")
          end
        end
      end

      context "and the iframe access level is for signed in visitors" do
        let(:meeting) { create :meeting, :published, :embed_in_meeting_page_iframe_embed_type, :online, :embeddable, :live, :signed_in_iframe_access_level, component: component }

        context "and user is not signed in" do
          it "doesn't show the meeting link embedded" do
            visit_meeting

            expect(page).to have_no_content("This meeting is happening right now")
            expect(page).to have_no_css("iframe")
          end
        end

        context "and user is signed in" do
          before do
            login_as user, scope: :user
          end

          it "shows the meeting link embedded" do
            visit_meeting

            expect(page).to have_content("This meeting is happening right now")
            expect(page).to have_css("iframe")
          end
        end
      end

      context "and the iframe access level is for registered visitors" do
        let(:meeting) do
          create(
            :meeting,
            :published,
            :embed_in_meeting_page_iframe_embed_type,
            :online,
            :embeddable,
            :live,
            :with_registrations_enabled,
            :registered_iframe_access_level,
            component: component
          )
        end
        let!(:registered_user) { create :user, :confirmed, organization: organization }
        let!(:registration) { create :registration, meeting: meeting, user: registered_user }

        context "and user is not signed in" do
          it "doesn't show the meeting link embedded" do
            visit_meeting

            expect(page).to have_no_content("This meeting is happening right now")
            expect(page).to have_no_css("iframe")
          end
        end

        context "and not registered user is signed in" do
          before do
            login_as user, scope: :user
          end

          it "doesn't show the meeting link embedded" do
            visit_meeting

            expect(page).to have_no_content("This meeting is happening right now")
            expect(page).to have_no_css("iframe")
          end
        end

        context "and registered user is signed in" do
          before do
            login_as registered_user, scope: :user
          end

          it "shows the meeting link embedded" do
            visit_meeting

            expect(page).to have_content("This meeting is happening right now")
            expect(page).to have_css("iframe")
          end
        end
      end

      context "and the meeting belongs to an assembly which is a transparent private space" do
        let(:assembly) { create(:assembly, :private, :transparent, organization: organization) }
        let(:participatory_space) { assembly }
        let(:admin) { create :user, :confirmed, :admin, organization: organization }
        let(:private_user) { create :user, :confirmed, organization: organization }
        let!(:assembly_private_user) { create :assembly_private_user, user: private_user, privatable_to: assembly }

        context "and user is not signed in" do
          it "doesn't show the meeting link embedded" do
            visit_meeting

            expect(page).to have_no_content("This meeting is happening right now")
            expect(page).to have_no_css("iframe")
          end
        end

        context "and user is signed in" do
          before do
            login_as user, scope: :user
          end

          it "doesn't show the meeting link embedded" do
            visit_meeting

            expect(page).to have_no_content("This meeting is happening right now")
            expect(page).to have_no_css("iframe")
          end
        end

        context "and private user is signed in" do
          before do
            login_as private_user, scope: :user
          end

          it "shows the meeting link embedded" do
            visit_meeting

            expect(page).to have_content("This meeting is happening right now")
            expect(page).to have_css("iframe")
          end
        end

        context "and admin user is signed in" do
          before do
            login_as admin, scope: :user
          end

          it "shows the meeting link embedded" do
            visit_meeting

            expect(page).to have_content("This meeting is happening right now")
            expect(page).to have_css("iframe")
          end
        end
      end
    end
  end

  context "when online meeting is not live and is not embedded" do
    let(:meeting) { create :meeting, :published, :online, :past, component: component }

    it "doesn't show the link to the live meeting streaming" do
      visit_meeting

      expect(page).to have_no_content("This meeting is happening right now")
    end
  end

  context "when online meeting is not live and is not embedded" do
    let(:meeting) { create :meeting, :published, :embed_in_meeting_page_iframe_embed_type, :online, :embeddable, component: component }

    it "shows the meeting link embedded" do
      visit_meeting

      expect(page).to have_css("iframe")
    end
  end

  describe "live meeting access" do
    let(:meeting) { create :meeting, :published, :online, component: component }
    let(:start_time) { meeting.start_time }
    let(:end_time) { meeting.end_time }

    around do |example|
      travel_to current_time do
        example.run
      end
    end

    before do
      visit_meeting
    end

    context "when current time is further than 10 minutes from the start time" do
      let(:current_time) { start_time - 20.minutes }

      it "is not live" do
        expect(page).to have_no_content("This meeting is happening right now")
      end
    end

    context "when current time is lesser than 10 minutes from the start time" do
      let(:current_time) { start_time - 5.minutes }

      it "is live" do
        expect(page).to have_content("This meeting is happening right now")
      end
    end

    context "when current time in between the start and the end time" do
      let(:current_time) { start_time + 1.minute }

      it "is live" do
        expect(page).to have_content("This meeting is happening right now")
      end
    end

    context "when current time has passed the end time" do
      let(:current_time) { end_time + 5.minutes }

      it "is not live" do
        expect(page).to have_no_content("This meeting is happening right now")
      end
    end
  end
end
