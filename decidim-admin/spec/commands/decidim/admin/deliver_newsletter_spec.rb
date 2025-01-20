# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe DeliverNewsletter do
    describe "call" do
      let(:organization) { create(:organization) }
      let(:newsletter) do
        create(:newsletter,
               organization:,
               body: Decidim::Faker::Localized.sentence(word_count: 3))
      end
      let(:current_user) { create(:user, :admin, :confirmed, organization:) }
      let(:participatory_processes) { create_list(:participatory_process, rand(2..9), organization:) }
      let(:selected_participatory_processes) { [participatory_processes.first.id.to_s] }
      let(:send_to_all_users) { false }
      let(:send_to_verified_users) { false }
      let(:verification_types) { [] }
      let(:send_to_followers) { false }
      let(:send_to_participants) { false }
      let(:send_to_private_members) { false }
      let(:participatory_space_types) { [] }
      let(:form_params) do
        {
          send_to_all_users:,
          send_to_verified_users:,
          verification_types:,
          send_to_followers:,
          send_to_participants:,
          send_to_private_members:,
          participatory_space_types:
        }
      end
      let(:form) do
        SelectiveNewsletterForm.from_params(
          form_params
        ).with_context(
          current_organization: organization,
          current_user:
        )
      end
      let(:command) { described_class.new(newsletter, form) }

      before do
        ActiveJob::Base.queue_adapter = :inline
      end

      def user_localized_body(user)
        newsletter.template.settings.body.stringify_keys[user.locale]
      end

      shared_examples_for "selective newsletter" do
        context "when everything is ok" do
          it "updates the counters and delivers to the right users" do
            clear_emails
            expect(emails.length).to eq(0)

            perform_enqueued_jobs { command.call }

            expect(emails.length).to eq(deliverable_users.count)

            deliverable_users.each do |user|
              email = emails.find { |e| e.to.include? user.email }
              expect(email_body(email)).to include(user_localized_body(user))
            end

            newsletter.reload
            expect(newsletter.total_deliveries).to eq(deliverable_users.count)
            expect(newsletter.total_recipients).to eq(deliverable_users.count)
          end

          it "logs the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with("deliver", newsletter, current_user)
              .and_call_original

            expect do
              perform_enqueued_jobs { command.call }
            end.to change(Decidim::ActionLog, :count)

            action_log = Decidim::ActionLog.last
            expect(action_log.version).to be_present
            expect(action_log.version.event).to eq "update"
          end
        end
      end

      context "when sending to all users" do
        let(:send_to_all_users) { true }

        context "without scopes segment" do
          let!(:deliverable_users) do
            create_list(:user, rand(2..9), :confirmed, organization:, newsletter_notifications_at: Time.current)
          end

          let!(:not_deliverable_users) do
            create_list(:user, rand(2..9), organization:, newsletter_notifications_at: nil)
          end

          let!(:unconfirmed_users) do
            create_list(:user, rand(2..9), organization:, newsletter_notifications_at: Time.current)
          end

          it_behaves_like "selective newsletter"
        end
      end

      context "when sending to verified users" do
        let(:send_to_verified_users) { true }

        context "when no verification types selected" do
          it "is not valid" do
            expect { command.call }.to broadcast(:no_recipients)
          end
        end

        context "with a single verification type is selected" do
          let(:verification_types) { ["id_documents"] }

          let!(:deliverable_users) do
            create_list(:user, rand(2..9), :confirmed, organization:, newsletter_notifications_at: Time.current)
          end

          let!(:undeliverable_users) do
            create_list(:user, rand(2..9), :confirmed, organization:, newsletter_notifications_at: Time.current)
          end

          let!(:unconfirmed_users) do
            create_list(:user, rand(2..9), organization:, newsletter_notifications_at: Time.current)
          end

          before do
            deliverable_users.each do |user|
              create(:authorization, user:, name: "id_documents", granted_at: Time.current)
            end
          end

          it_behaves_like "selective newsletter"
        end

        context "with multiple verification types selected" do
          let(:verification_types) { %w(id_documents postal_letter) }
          let!(:deliverable_users) { users_with_id_documents + users_with_postal_letter }

          let!(:users_with_id_documents) do
            create_list(:user, rand(2..9), :confirmed, organization:, newsletter_notifications_at: Time.current)
          end

          let!(:users_with_postal_letter) do
            create_list(:user, rand(2..9), :confirmed, organization:, newsletter_notifications_at: Time.current)
          end

          before do
            users_with_id_documents.each do |user|
              create(:authorization, user:, name: "id_documents", granted_at: Time.current)
            end

            users_with_postal_letter.each do |user|
              create(:authorization, user:, name: "postal_letter", granted_at: Time.current)
            end
          end

          it_behaves_like "selective newsletter"
        end
      end

      context "when sending to followers" do
        let(:send_to_followers) { true }

        context "when no spaces selected" do
          it "is not valid" do
            expect { command.call }.to broadcast(:invalid)
          end
        end

        context "when spaces selected" do
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

          let!(:deliverable_users) do
            create_list(:user, rand(2..9), :confirmed, organization:, newsletter_notifications_at: Time.current)
          end

          let!(:undeliverable_users) do
            create_list(:user, rand(2..9), :confirmed, organization:, newsletter_notifications_at: Time.current)
          end

          before do
            deliverable_users.each do |follower|
              create(:follow, followable: participatory_processes.first, user: follower)
            end
          end

          it_behaves_like "selective newsletter"
        end
      end

      context "when sending to participants" do
        let(:send_to_participants) { true }

        context "when no spaces selected" do
          it "is not valid" do
            expect { command.call }.to broadcast(:invalid)
          end
        end

        context "when spaces selected" do
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

          let!(:deliverable_users) do
            create_list(:user, rand(2..9), :confirmed, organization:, newsletter_notifications_at: Time.current)
          end

          let!(:undeliverable_users) do
            create_list(:user, rand(2..9), :confirmed, organization:, newsletter_notifications_at: Time.current)
          end

          before do
            deliverable_users.each do |participant|
              create(:dummy_resource, component:, author: participant, published_at: Time.current)
            end
          end

          it_behaves_like "selective newsletter"
        end
      end

      context "when sending to followers and participants" do
        let(:component) { create(:dummy_component, organization:) }
        let(:send_to_participants) { true }
        let(:send_to_followers) { true }

        let!(:participant_users) do
          create_list(:user, rand(2..9), :confirmed, organization:, newsletter_notifications_at: Time.current)
        end

        let!(:follower_users) do
          create_list(:user, rand(2..9), :confirmed, organization:, newsletter_notifications_at: Time.current)
        end

        let!(:deliverable_users) { participant_users + follower_users }

        let!(:undeliverable_users) do
          create_list(:user, rand(2..9), :confirmed, organization:, newsletter_notifications_at: Time.current)
        end

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

        before do
          participant_users.each do |participant|
            create(:dummy_resource, component:, author: participant, published_at: Time.current)
          end

          follower_users.each do |follower|
            create(:follow, followable: component.participatory_space, user: follower)
          end
        end

        it_behaves_like "selective newsletter"
      end

      context "when sending to private members" do
        let(:send_to_private_members) { true }

        context "when no spaces selected" do
          it "is not valid" do
            expect { command.call }.to broadcast(:invalid)
          end
        end

        context "when spaces selected" do
          let!(:participatory_process) { create(:participatory_process, organization:, private_space: true) }
          let!(:component) { create(:dummy_component, organization:, participatory_space: participatory_process) }
          let!(:private_users) do
            create_list(:participatory_space_private_user, 30) do |private_user|
              private_user.user = create(:user, :confirmed, newsletter_notifications_at: Time.current, organization:)
              private_user.privatable_to = participatory_process
              private_user.save!
            end
          end
          let(:participatory_space_types) do
            [
              { "id" => nil,
                "manifest_name" => "participatory_processes",
                "ids" => [participatory_process.id.to_s] },
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

          let!(:deliverable_users) { Decidim::User.where(id: private_users.map(&:decidim_user_id)) }

          let!(:undeliverable_users) do
            create_list(:user, rand(2..9), :confirmed, organization:, newsletter_notifications_at: Time.current)
          end

          it_behaves_like "selective newsletter"
        end
      end

      context "when the user is a space admin" do
        let(:user) { create(:user, organization:) }
        let(:component) { create(:dummy_component, organization:) }

        let(:participatory_process_user_role) do
          build(
            :participatory_process_user_role,
            user:,
            participatory_process: component.participatory_space,
            role: "admin"
          )
        end

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

        let!(:deliverable_users) do
          create_list(:user, rand(2..9), :confirmed, organization:, newsletter_notifications_at: Time.current)
        end

        context "when sending to all space participants" do
          let(:send_to_participants) { true }

          before do
            deliverable_users.each do |participant|
              create(:dummy_resource, component:, author: participant, published_at: Time.current)
            end
          end

          it_behaves_like "selective newsletter"
        end
      end
    end
  end
end
