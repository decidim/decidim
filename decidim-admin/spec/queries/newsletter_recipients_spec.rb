# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe NewsletterRecipients do
    subject { described_class.new(form) }

    let(:newsletter) { create :newsletter }
    let(:organization) { newsletter.organization }
    let(:send_to_all_users) { true }
    let(:send_to_followers) { false }
    let(:send_to_participants) { false }
    let(:participatory_space_types) { [] }
    let(:scope_ids) { [] }

    let(:form_params) do
      {
        send_to_all_users: send_to_all_users,
        send_to_followers: send_to_followers,
        send_to_participants: send_to_participants,
        participatory_space_types: participatory_space_types,
        scope_ids: scope_ids
      }
    end

    let(:form) do
      SelectiveNewsletterForm.from_params(
        form_params
      ).with_context(
        current_organization: organization
      )
    end

    describe "querying recipients" do
      context "when sending to all users" do
        let!(:recipients) { create_list(:user, 5, :confirmed, newsletter_notifications_at: Time.current, organization: organization) }

        it "returns all users" do
          expect(subject.query).to match_array recipients
          expect(recipients.count).to eq 5
        end

        context "with the scope_ids array containing an empty value" do
          let(:scope_ids) { [""] }

          it "returns all users" do
            expect(subject.query).to match_array recipients
            expect(recipients.count).to eq 5
          end
        end
      end

      context "when sending to followers" do
        let!(:recipients) { create_list(:user, 3, :confirmed, newsletter_notifications_at: Time.current, organization: organization) }
        let(:send_to_all_users) { false }
        let(:send_to_followers) { true }
        let(:participatory_processes) { create_list(:participatory_process, 2, organization: organization) }
        let(:participatory_space_types) do
          [
            { "id" => nil,
              "manifest_name" => "participatory_processes",
              "ids" => [participatory_processes.first.id.to_s] },
            { "id" => nil,
              "manifest_name" => "assemblies",
              "ids" => [] },
            { "id" => nil,
              "manifest_name" => "conferences",
              "ids" => [] },
            { "id" => nil,
              "manifest_name" => "consultations",
              "ids" => [] },
            { "id" => nil,
              "manifest_name" => "initiatives",
              "ids" => [] }
          ]
        end

        context "when recipients follow the participatory space" do
          before do
            recipients.each do |follower|
              create(:follow, followable: participatory_processes.first, user: follower)
            end
          end

          it "returns all users" do
            expect(subject.query).to match_array recipients
            expect(recipients.count).to eq 3
          end
        end
      end

      context "when sending to participants" do
        let(:send_to_all_users) { false }
        let(:send_to_participants) { true }
        let!(:component) { create(:dummy_component, organization: organization) }
        let(:participatory_space_types) do
          [
            { "id" => nil,
              "manifest_name" => "participatory_processes",
              "ids" => [component.participatory_space.id.to_s] },
            { "id" => nil,
              "manifest_name" => "assemblies",
              "ids" => [] },
            { "id" => nil,
              "manifest_name" => "conferences",
              "ids" => [] },
            { "id" => nil,
              "manifest_name" => "consultations",
              "ids" => [] },
            { "id" => nil,
              "manifest_name" => "initiatives",
              "ids" => [] },
            { "id" => nil,
              "manifest_name" => "votings",
              "ids" => [component.participatory_space.id.to_s] }
          ]
        end

        context "when recipients participate to the participatory space" do
          let!(:authors) do
            create_list(:user, 3, :confirmed, organization: organization, newsletter_notifications_at: Time.current)
          end

          before do
            authors.each do |participant|
              create(:dummy_resource, :published, component: component, author: participant)
            end
          end

          it "returns all users" do
            expect(subject.query).to match_array authors
            expect(authors.count).to eq 3
          end

          context "and other comment in other participatory spaces" do
            # non participant commentator (comments into other spaces)
            let!(:non_participant) { create(:user, :confirmed, newsletter_notifications_at: Time.current, organization: organization) }
            let!(:component_out_of_newsletter) { create(:dummy_component, organization: organization) }
            let!(:resource_out_of_newsletter) { create(:dummy_resource, :published, author: non_participant, component: component_out_of_newsletter) }
            let!(:outlier_comment) { create(:comment, author: non_participant, commentable: resource_out_of_newsletter) }
            # participant commentator
            let!(:commentator_participant) { create(:user, :confirmed, newsletter_notifications_at: Time.current, organization: organization) }
            let!(:resource_in_newsletter) { create(:dummy_resource, :published, author: authors.first, component: component) }
            let!(:comment_in_newsletter) { create(:comment, author: commentator_participant, commentable: resource_in_newsletter) }

            let(:recipients) { authors + [commentator_participant] }

            it "returns only commenters in the selected spaces" do
              expect(subject.query).to match_array(recipients)
              expect(recipients.count).to eq 4
            end
          end
        end
      end

      context "with scopes segment" do
        let(:scopes) do
          create_list(:scope, 5, organization: organization)
        end
        let(:scope_ids) { scopes.pluck(:id) }

        context "when recipients interested in scopes" do
          let!(:recipients) do
            create_list(:user, 3, :confirmed, organization: organization, newsletter_notifications_at: Time.current, extended_data: { "interested_scopes" => scopes.first.id })
          end

          it "returns all users" do
            expect(subject.query).to match_array recipients
            expect(recipients.count).to eq 3
          end
        end

        context "when interest not match the selected scopes" do
          let(:user_interset) { create(:scope, organization: organization) }
          let!(:recipients) do
            create_list(:user, 3, :confirmed, organization: organization, newsletter_notifications_at: Time.current, extended_data: { "interested_scopes" => user_interset.id })
          end

          it "don't return recipients" do
            expect(subject.query).to match_array []
          end
        end
      end
    end
  end
end
