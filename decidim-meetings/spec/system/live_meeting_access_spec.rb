# frozen_string_literal: true

require "spec_helper"

describe "Meeting live event access" do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let!(:user) { create(:user, :confirmed, organization:) }
  let(:meeting_live_event_path) do
    decidim_participatory_process_meetings.meeting_live_event_path(
      participatory_process_slug: participatory_process.slug,
      component_id: component.id,
      meeting_id: meeting.id,
      locale: I18n.locale
    )
  end

  def visit_meeting
    visit resource_locator(meeting).path
  end

  context "when online meeting is live" do
    shared_examples "iframe access levels" do |embedding_type|
      context "when the iframe access level is for all visitors" do
        before do
          meeting.iframe_access_level_all!
        end

        context "and user is signed in" do
          before do
            login_as user, scope: :user
          end

          it "shows the meeting link embedded" do
            visit_meeting

            expect(page).to have_content("This meeting is happening right now")
            case embedding_type
            when :embedded
              expect(page).to have_css("iframe")
            else
              expect(page).to have_content("Join meeting")
            end
          end
        end
      end

      context "and the iframe access level is for signed in visitors" do
        before do
          meeting.iframe_access_level_signed_in!
        end

        context "and user is not signed in" do
          it "does not show the meeting link embedded" do
            visit_meeting

            expect(page).to have_no_content("This meeting is happening right now")
            case embedding_type
            when :embedded
              expect(page).to have_no_css("iframe")
            else
              expect(page).to have_no_content("Join meeting")
            end
          end
        end

        context "and user is signed in" do
          before do
            login_as user, scope: :user
          end

          it "shows the meeting link embedded" do
            visit_meeting

            expect(page).to have_content("This meeting is happening right now")
            case embedding_type
            when :embedded
              expect(page).to have_css("iframe")
            else
              expect(page).to have_content("Join meeting")
            end
          end

          context "when cookies rejected" do
            before { data_consent(false, visit_root: true) }

            it "shows cookie warning" do
              visit_meeting

              expect(page).to have_content("This meeting is happening right now")
              case embedding_type
              when :embedded
                expect(page).to have_content("You need to enable all cookies in order to see this content")
                expect(page).to have_no_css("iframe")
              else
                expect(page).to have_content("Join meeting")
              end
            end
          end
        end
      end

      context "and the iframe access level is for registered visitors" do
        before do
          meeting.iframe_access_level_registered!
        end

        let!(:registered_user) { create(:user, :confirmed, organization:) }
        let!(:registration) { create(:registration, meeting:, user: registered_user) }

        context "and user is not signed in" do
          it "does not show the meeting link embedded" do
            visit_meeting

            expect(page).to have_no_content("This meeting is happening right now")
            case embedding_type
            when :embedded
              expect(page).to have_no_css("iframe")
            else
              expect(page).to have_no_content("Join meeting")
            end
          end
        end

        context "and not registered user is signed in" do
          before do
            login_as user, scope: :user
          end

          it "does not show the meeting link embedded" do
            visit_meeting

            expect(page).to have_no_content("This meeting is happening right now")
            case embedding_type
            when :embedded
              expect(page).to have_no_css("iframe")
            else
              expect(page).to have_no_content("Join meeting")
            end
          end
        end

        context "and registered user is signed in" do
          before do
            login_as registered_user, scope: :user
          end

          it "shows the meeting link embedded" do
            visit_meeting

            expect(page).to have_content("This meeting is happening right now")
            case embedding_type
            when :embedded
              expect(page).to have_css("iframe")
            else
              expect(page).to have_content("Join meeting")
            end
          end
        end
      end
    end

    shared_examples "belonging to an assembly which is a transparent private space" do
      let(:assembly) { create(:assembly, :private, :transparent, organization:) }
      let(:participatory_space) { assembly }
      let(:admin) { create(:user, :confirmed, :admin, organization:) }
      let(:private_user) { create(:user, :confirmed, organization:) }
      let!(:assembly_private_user) { create(:assembly_private_user, user: private_user, privatable_to: assembly) }

      context "when user is not signed in" do
        it "does not show the meeting link embedded" do
          visit_meeting

          expect(page).to have_no_content("This meeting is happening right now")
        end
      end

      context "when user is signed in" do
        before do
          login_as user, scope: :user
        end

        it "does not show the meeting link embedded" do
          visit_meeting

          expect(page).to have_no_content("This meeting is happening right now")
        end
      end

      context "when private user is signed in" do
        before do
          login_as private_user, scope: :user
        end

        it "shows the meeting link embedded" do
          visit_meeting

          expect(page).to have_content("This meeting is happening right now")
        end
      end

      context "when admin user is signed in" do
        before do
          login_as admin, scope: :user
        end

        it "shows the meeting link embedded" do
          visit_meeting

          expect(page).to have_content("This meeting is happening right now")
        end
      end
    end

    context "and the iframe_embed_type is none" do
      let(:meeting) { create(:meeting, :published, :online, :live, component:) }

      it "does not show the link to the live meeting streaming" do
        visit_meeting

        expect(page).to have_no_content("This meeting is happening right now")
      end
    end

    context "and the iframe_embed_type is 'embed_in_meeting_page'" do
      let(:meeting) { create(:meeting, :published, :embed_in_meeting_page_iframe_embed_type, :online, :embeddable, :live, component:) }

      context "and the meeting URL is not embeddable" do
        let(:meeting) { create(:meeting, :published, :embed_in_meeting_page_iframe_embed_type, :online, :live, component:) }

        it "shows the link to the live meeting streaming" do
          visit_meeting

          expect(page).to have_content("This meeting is happening right now")
        end
      end

      context "when cookies accepted" do
        before { data_consent(true, visit_root: true) }

        it "shows the meeting link embedded" do
          visit_meeting

          expect(page).to have_css("iframe")
        end

        it_behaves_like "iframe access levels", :embedded
        it_behaves_like "belonging to an assembly which is a transparent private space"
      end
    end

    context "and the iframe_embed_type is 'open_in_live_event_page'" do
      let(:meeting) { create(:meeting, :published, :online, :open_in_live_event_page_iframe_embed_type, :live, :embeddable, component:) }

      it "shows the link to the live meeting streaming" do
        visit_meeting

        new_window = window_opened_by { click_on "Join meeting" }

        within_window new_window do
          expect(page).to have_current_path(meeting_live_event_path)
        end
      end

      context "and the meeting URL is not embeddable" do
        let(:meeting) { create(:meeting, :published, :online, :open_in_live_event_page_iframe_embed_type, :live, component:) }

        it "shows the link to the external streaming service" do
          visit_meeting

          expect(page).to have_link("Join meeting", href: meeting.online_meeting_url)
        end
      end

      context "when cookies accepted" do
        before do
          data_consent(true, visit_root: true)
        end

        it_behaves_like "iframe access levels", :live_event_page
        it_behaves_like "belonging to an assembly which is a transparent private space"
      end
    end

    context "and the iframe_embed_type is 'open_in_new_tab'" do
      let(:meeting) { create(:meeting, :published, :online, :open_in_new_tab_iframe_embed_type, :live, component:) }

      it "shows the link to the meeting URL" do
        visit_meeting

        expect(page).to have_link("Join meeting", href: meeting.online_meeting_url)
      end

      it_behaves_like "belonging to an assembly which is a transparent private space"
    end
  end

  context "when online meeting is not live and is not embedded" do
    let(:meeting) { create(:meeting, :published, :online, :past, component:) }

    it "does not show the link to the live meeting streaming" do
      visit_meeting

      expect(page).to have_no_content("This meeting is happening right now")
    end
  end

  context "when online meeting is not live and it is embedded" do
    let(:meeting) { create(:meeting, :published, :embed_in_meeting_page_iframe_embed_type, :online, :embeddable, component:) }

    it "does not show the meeting link embedded" do
      visit_meeting

      expect(page).to have_no_css("iframe")
    end
  end

  describe "when a meeting link is available signed in" do
    let!(:meeting) { create(:meeting, :published, :signed_in_iframe_access_level, :online, component:) }

    context "when user is not signed in" do
      it "not shown to not signed in users" do
        visit_meeting

        expect(page).to have_no_css(".address__hints")
        expect(page).to have_no_content(meeting.online_meeting_url)
      end
    end

    context "when user is signed in" do
      before do
        login_as user, scope: :user
      end

      it "shown to signed in users" do
        visit_meeting

        expect(page).to have_css(".address__hints")
        expect(page).to have_content(meeting.online_meeting_url)
      end
    end
  end

  describe "when a meeting link is available as a registered user" do
    let!(:meeting) { create(:meeting, :published, :registered_iframe_access_level, :online, component:) }
    let!(:registered_user) { create(:user, :confirmed, organization:) }
    let!(:registration) { create(:registration, meeting:, user: registered_user) }

    context "when user is not registered" do
      it "not shown to registered users" do
        visit_meeting

        expect(page).to have_no_css(".address__hints")
        expect(page).to have_no_content(meeting.online_meeting_url)
      end
    end

    context "when user is registered" do
      before do
        login_as registered_user, scope: :user
      end

      it "is shown to registered users" do
        visit_meeting

        expect(page).to have_css(".address__hints")
        expect(page).to have_content(meeting.online_meeting_url)
      end
    end
  end

  describe "live meeting access" do
    let(:meeting) { create(:meeting, :published, :online, :embed_in_meeting_page_iframe_embed_type, component:) }
    let(:start_time) { meeting.start_time }
    let(:end_time) { meeting.end_time }

    before do
      travel_to current_time
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
