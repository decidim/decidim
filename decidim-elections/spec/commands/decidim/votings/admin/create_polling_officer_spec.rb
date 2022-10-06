# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Votings
    module Admin
      describe CreatePollingOfficer do
        subject { described_class.new(form, current_user, voting) }

        let!(:existing_user) { create :user, email: user_email, organization: voting.organization }
        let!(:current_user) { create :user, email: ::Faker::Internet.email, organization: voting.organization }
        let(:voting) { create :voting }
        let(:name) { ::Faker::Name.name }
        let(:email) { ::Faker::Internet.email }
        let(:user) { existing_user }
        let(:user_email) { "existing_user@example.org" }
        let(:form) do
          double(
            invalid?: invalid,
            email:,
            name:,
            current_participatory_space: voting,
            user:
          )
        end
        let(:invalid) { false }

        context "when the form is not valid" do
          let(:invalid) { true }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when using an existing user" do
          it "creates the polling officer" do
            subject.call

            expect(Decidim::Votings::PollingOfficer.count).to eq 1
            expect(Decidim::Votings::PollingOfficer.first.voting).to eq voting
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with(:create, Decidim::Votings::PollingOfficer, current_user, resource: hash_including(:title))
              .and_call_original

            expect { subject.call }.to change(Decidim::ActionLog, :count)
            action_log = Decidim::ActionLog.last
            expect(action_log.version).to be_present
          end
        end

        context "when inviting a new user" do
          let(:user) { nil }

          describe "when the email is not taken" do
            let(:email) { "not_yet_existing@example.com" }

            it "creates a new user" do
              subject.call
              created_user = Decidim::User.last
              expect(created_user.email).to eq(email)
            end
          end

          describe "when the email already exists" do
            let(:email) { user_email }

            it "doesn't create a new user" do
              expect { subject.call }.to broadcast(:ok)

              polling_officers = Decidim::Votings::PollingOfficer.where(user: existing_user)

              expect(polling_officers.count).to eq 1
            end

            it "resends the invitation if the user hasn't accepted it yet" do
              existing_user.invite!

              expect { subject.call }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
            end
          end
        end
      end
    end
  end
end
