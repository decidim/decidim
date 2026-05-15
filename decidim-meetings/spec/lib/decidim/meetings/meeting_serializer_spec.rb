# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Meetings
    describe MeetingSerializer do
      subject do
        described_class.new(meeting)
      end

      let!(:meeting) { create(:meeting, :published, contributions_count: 5, attendees_count: 10, attending_organizations: "Some organization") }
      let!(:taxonomies) { create_list(:taxonomy, 2, :with_parent, organization: component.organization) }
      let(:participatory_process) { component.participatory_space }
      let(:component) { meeting.component }

      let(:accountability_component) do
        create(:component, manifest_name: :accountability, participatory_space: meeting.component.participatory_space)
      end
      let(:results) { create_list(:result, 2, component: accountability_component) }
      let(:proposal_component) do
        create(:component, manifest_name: :proposals, participatory_space: meeting.component.participatory_space)
      end
      let(:proposals) { create_list(:proposal, 2, component: proposal_component) }
      let(:serialized_taxonomies) do
        { ids: taxonomies.pluck(:id) }.merge(taxonomies.to_h { |t| [t.id, t.name] })
      end

      before do
        meeting.update!(taxonomies:)
        meeting.link_resources(proposals, "proposals_from_meeting")
        meeting.link_resources(results, "meetings_through_proposals")
      end

      # Internal field for admins. Test is implemented to make sure salt is not published
      describe "salt" do
        it "is not published" do
          expect(subject.serialize).not_to have_key(:salt)
        end
      end

      describe "#serialize" do
        let(:serialized) { subject.serialize }

        it "serializes the id" do
          expect(serialized).to include(id: meeting.id)
        end

        it "serializes the taxonomies" do
          expect(serialized[:taxonomies]).to eq(serialized_taxonomies)
        end

        it "serializes the title" do
          expect(serialized).to include(title: meeting.title)
        end

        it "serializes the description" do
          expect(serialized).to include(description: meeting.description)
        end

        it "serializes the start time" do
          expect(serialized).to include(start_time: meeting.start_time)
        end

        it "serializes the end time" do
          expect(serialized).to include(end_time: meeting.end_time)
        end

        it "serializes the amount of attendees" do
          expect(serialized).to include(attendees: meeting.attendees_count)
        end

        it "serializes the address" do
          expect(serialized).to include(address: meeting.address)
        end

        it "serializes the url" do
          expect(serialized[:url]).to include("http", meeting.id.to_s)
        end

        it "serializes the component" do
          expect(serialized[:component]).to include(id: meeting.component.id)
        end

        it "serializes the participatory space" do
          expect(serialized[:participatory_space]).to include(id: participatory_process.id)
          expect(serialized[:participatory_space][:url]).to include("http", participatory_process.slug)
        end

        it "serializes the reference" do
          expect(serialized).to include(reference: meeting.reference)
        end

        it "serializes the amount of attachments" do
          expect(serialized).to include(attachments: meeting.attachments.count)
        end

        it "serializes related proposals" do
          expect(serialized[:related_proposals].length).to eq(2)
          expect(serialized[:related_proposals].first).to match(%r{http.*/proposals})
        end

        it "serializes related results" do
          expect(serialized[:related_results].length).to eq(2)
          expect(serialized[:related_results].first).to match(%r{http.*/results})
        end

        it "serialized the published column" do
          expect(serialized).to include(published: meeting.published?)
        end

        it "serializes the hint of the meeting location" do
          expect(serialized).to include(location_hints: meeting.location_hints)
        end

        it "serializes the created at date" do
          expect(serialized).to include(created_at: meeting.created_at)
        end

        it "serializes the updated at date" do
          expect(serialized).to include(updated_at: meeting.updated_at)
        end

        it "serializes the latitude" do
          expect(serialized).to include(latitude: meeting.latitude)
        end

        it "serializes the longitude" do
          expect(serialized).to include(longitude: meeting.longitude)
        end

        it "serializes the number of followers to the meeting" do
          expect(serialized).to include(follows_count: meeting.follows_count)
        end

        it "serializes whether it is a private meeting" do
          expect(serialized).to include(private_meeting: meeting.private_meeting)
        end

        it "serializes the transparency of the meeting for non-members" do
          expect(serialized).to include(transparent: meeting.transparent)
        end

        it "serializes whether the registration form was enabled or not" do
          expect(serialized).to include(registration_form_enabled: meeting.registration_form_enabled)
        end

        it "serializes the start time of comments" do
          expect(serialized[:comments]).to include(start_time: meeting.comments_start_time)
        end

        it "serializes the end time of comments" do
          expect(serialized[:comments]).to include(end_time: meeting.comments_end_time)
        end

        it "serializes whether comments are enabled" do
          expect(serialized[:comments]).to include(enabled: meeting.comments_enabled)
        end

        it "serializes the number of comments" do
          expect(serialized[:comments]).to include(count: meeting.comments_count)
        end

        it "serializes the online meeting url" do
          expect(serialized).to include(online_meeting_url: meeting.online_meeting_url)
        end

        it "serializes the registration url" do
          expect(serialized).to include(registration_url: meeting.registration_url)
        end

        it "serializes the author id" do
          expect(serialized[:author]).to include(id: meeting.author.id)
        end

        it "serializes the author type" do
          expect(serialized).to include(decidim_author_type: meeting.decidim_author_type)
        end

        it "serializes the closing date" do
          expect(serialized).to include(closed_at: meeting.closed_at)
        end

        it "serializes the registration terms of the meeting" do
          expect(serialized).to include(registration_terms: meeting.registration_terms)
        end

        it "serializes the available slots of the meeting" do
          expect(serialized).to include(available_slots: meeting.available_slots)
        end

        it "serializes the if registrations were activated" do
          expect(serialized).to include(registrations_enabled: meeting.registrations_enabled)
        end

        it "serializes the custom registration email" do
          expect(serialized).to include(customize_registration_email: meeting.customize_registration_email)
        end

        it "serializes the type of meeting" do
          expect(serialized).to include(type_of_meeting: meeting.type_of_meeting)
        end

        it "serializes the iframe access level" do
          expect(serialized).to include(iframe_access_level: meeting.iframe_access_level)
        end

        it "serializes the iframe_embed_type" do
          expect(serialized).to include(iframe_embed_type: meeting.iframe_embed_type)
        end

        it "serializes the reserved slots of the meeting" do
          expect(serialized).to include(reserved_slots: meeting.reserved_slots)
        end

        it "serializes the registration type" do
          expect(serialized).to include(registration_type: meeting.registration_type)
        end

        it "does not serialize the custom registration email content" do
          expect(serialized).not_to include(registration_email_custom_content: meeting.registration_email_custom_content)
        end

        describe "meeting location and iframe access level" do
          context "when iframe_access_level is set to registered" do
            before do
              meeting.update!(iframe_access_level: :registered)
            end

            it "does not serialize the location" do
              expect(serialized).not_to include(location: meeting.location)
            end
          end

          context "when iframe_access_level is set to signed_in" do
            before do
              meeting.update!(iframe_access_level: :signed_in)
            end

            it "does not serialize the location" do
              expect(serialized).not_to include(location: meeting.location)
            end
          end

          context "when iframe_access_level is all" do
            before do
              meeting.update!(iframe_access_level: :all)
            end

            it "serializes the location" do
              expect(serialized).to include(location: meeting.location)
            end
          end
        end

        describe "closing report and visibility" do
          context "when the meeting is completed" do
            let!(:meeting) { create(:meeting, :closed) }

            it "serializes the closing report" do
              expect(serialized).to include(closing_report: meeting.closing_report)
            end

            it "serializes the whether the meeting was visible or not" do
              expect(serialized).to include(closing_visible: meeting.closing_visible)
            end
          end

          context "when the meeting is not visible" do
            let!(:meeting) { create(:meeting, closing_visible: nil) }

            it "does not serialize the closing report" do
              expect(serialized[:closing_report]).to be_nil
            end

            it "does not serialize the meeting's visibility" do
              expect(serialized[:closing_visible]).to be_nil
            end
          end
        end

        describe "contributions and visibility" do
          context "when the meeting is completed" do
            let!(:meeting) { create(:meeting, :closed) }

            it "serializes the amount of contributions" do
              expect(serialized).to include(contributions: meeting.contributions_count)
            end

            it "serializes the whether the meeting was visible or not" do
              expect(serialized).to include(closing_visible: meeting.closing_visible)
            end
          end

          context "when the meeting is not visible" do
            let!(:meeting) { create(:meeting, closing_visible: nil) }

            it "does not serialize the meetings contributions" do
              expect(serialized[:contributions]).to eq(0)
            end

            it "does not serialize the meeting's visibility" do
              expect(serialized[:closing_visible]).to be_nil
            end
          end
        end

        describe "attending organizations and their visibility" do
          context "when the meeting is completed" do
            let!(:meeting) { create(:meeting, :closed) }

            it "serializes the amount of attending organizations" do
              expect(serialized).to include(attending_organizations: meeting.attending_organizations)
            end

            it "serializes the whether the meeting was visible or not" do
              expect(serialized).to include(closing_visible: meeting.closing_visible)
            end
          end

          context "when the meeting is not visible" do
            let!(:meeting) { create(:meeting, closing_visible: nil) }

            it "does not serialize the meetings attending organizations" do
              expect(serialized[:attending_organizations]).to be_nil
            end

            it "does not serialize the meeting's visibility" do
              expect(serialized[:closing_visible]).to be_nil
            end
          end
        end

        describe "attendees and their visibility" do
          context "when the meeting is completed" do
            let!(:meeting) { create(:meeting, :closed) }

            it "serializes the amount of attendees" do
              expect(serialized).to include(attendees: meeting.attendees_count.to_i)
            end

            it "serializes the whether the meeting was visible or not" do
              expect(serialized).to include(closing_visible: meeting.closing_visible)
            end
          end

          context "when the meeting is not visible" do
            let!(:meeting) { create(:meeting, closing_visible: nil) }

            it "does not serialize the attendees" do
              expect(serialized[:attendees]).to eq(0)
            end

            it "does not serialize the meeting's visibility" do
              expect(serialized[:closing_visible]).to be_nil
            end
          end
        end

        describe "videos and their visibility" do
          context "when the meeting is completed" do
            let!(:meeting) { create(:meeting, :closed) }

            it "serializes the meeting video" do
              expect(serialized).to include(video_url: meeting.video_url)
            end

            it "serializes the whether the meeting was visible or not" do
              expect(serialized).to include(closing_visible: meeting.closing_visible)
            end
          end

          context "when the meeting is not visible" do
            let!(:meeting) { create(:meeting, closing_visible: nil) }

            it "does not serialize the attendees" do
              expect(serialized[:video_url]).to be_nil
            end

            it "does not serialize the meeting's visibility" do
              expect(serialized[:closing_visible]).to be_nil
            end
          end
        end

        describe "meeting audio and its visibility" do
          context "when the meeting is completed" do
            let!(:meeting) { create(:meeting, :closed) }

            it "serializes the meeting audio" do
              expect(serialized).to include(audio_url: meeting.audio_url)
            end

            it "serializes the whether the meeting was visible or not" do
              expect(serialized).to include(closing_visible: meeting.closing_visible)
            end
          end

          context "when the meeting is not visible" do
            let!(:meeting) { create(:meeting, closing_visible: nil) }

            it "does not serialize the attendees" do
              expect(serialized[:audio_url]).to be_nil
            end

            it "does not serialize the meeting's visibility" do
              expect(serialized[:closing_visible]).to be_nil
            end
          end
        end
      end
    end
  end
end
