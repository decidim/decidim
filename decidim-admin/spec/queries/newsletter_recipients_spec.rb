# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe NewsletterRecipients do
    subject { described_class.new(form) }

    let(:newsletter) { create(:newsletter) }
    let(:organization) { newsletter.organization }
    let(:send_to_all_users) { true }
    let(:send_to_followers) { false }
    let(:send_to_participants) { false }
    let(:send_to_verified_users) { false }
    let(:send_to_private_members) { false }
    let(:participatory_space_types) { [] }
    let(:verification_types) { [] }

    let(:form_params) do
      {
        send_to_all_users:,
        send_to_followers:,
        send_to_participants:,
        send_to_verified_users:,
        send_to_private_members:,
        participatory_space_types:,
        verification_types:
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
        let!(:recipients) { create_list(:user, 5, :confirmed, newsletter_notifications_at: Time.current, organization:) }

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

        context "with blocked accounts" do
          let!(:blocked_recipients) { create_list(:user, 5, :confirmed, :blocked, newsletter_notifications_at: Time.current, organization:) }

          it "returns all not blocked users" do
            expect(subject.query).to match_array recipients
            expect(recipients.count).to eq 5
          end
        end
      end

      context "when sending to followers" do
        let!(:recipients) { create_list(:user, 3, :confirmed, newsletter_notifications_at: Time.current, organization:) }
        let(:send_to_all_users) { false }
        let(:send_to_followers) { true }
        let(:participatory_processes) { create_list(:participatory_process, 2, organization:) }
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
        let!(:component) { create(:dummy_component, organization:) }
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
              "manifest_name" => "initiatives",
              "ids" => [] }
          ]
        end

        context "when recipients participate in the participatory space" do
          let!(:authors) do
            create_list(:user, 3, :confirmed, organization:, newsletter_notifications_at: Time.current)
          end

          before do
            authors.each do |participant|
              create(:dummy_resource, :published, component:, author: participant)
            end
          end

          it "returns all users" do
            expect(subject.query).to match_array authors
            expect(authors.count).to eq 3
          end
        end
      end

      context "when sending to verified users" do
        let(:send_to_all_users) { false }
        let(:send_to_verified_users) { true }
        let!(:verified_users) { create_list(:user, 3, :confirmed, organization:, newsletter_notifications_at: Time.current) }
        let(:verification_types) { ["example"] }

        before do
          verified_users.each do |user|
            create(:authorization, name: "example", granted_at: Time.current, user:)
          end
        end

        it "returns verified users only" do
          expect(subject.query).to match_array verified_users
          expect(verified_users.count).to eq 3
        end
      end

      context "when sending to private members" do
        let(:send_to_all_users) { false }
        let(:send_to_private_members) { true }
        let!(:recipients) { create_list(:user, 3, :confirmed, newsletter_notifications_at: Time.current, organization:) }
        let(:participatory_process) { create(:participatory_process, organization:, private_space: true) }
        let(:participatory_space_types) do
          [
            { "id" => nil,
              "manifest_name" => "participatory_processes",
              "ids" => [participatory_process.id.to_s] }
          ]
        end

        before do
          recipients.each do |member|
            create(:participatory_space_private_user, privatable_to: participatory_process, user: member)
          end
        end

        it "returns private members only" do
          expect(subject.query).to match_array recipients
          expect(recipients.count).to eq 3
        end
      end
    end
  end
end
