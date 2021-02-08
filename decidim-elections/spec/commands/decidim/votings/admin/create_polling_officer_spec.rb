# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Votings
    module Admin
      describe CreatePollingOfficer do
        subject { described_class.new(form, current_user, voting) }

        let!(:existing_user) { create :user, email: existing_user_email, organization: voting.organization }
        let!(:current_user) { create :user, email: ::Faker::Internet.email, organization: voting.organization }
        let(:voting) { create :voting }
        let(:name) { ::Faker::Name.name }
        let(:email) { ::Faker::Internet.email }
        let(:existing_user_email) { "existing_user@example.org" }
        let(:form) do
          double(
            invalid?: invalid,
            email: email,
            name: name,
            current_participatory_space: voting
          )
        end
        let(:invalid) { false }

        context "when the form is not valid" do
          let(:invalid) { true }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when everything is ok" do
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

          context "when there is no user with the given email" do
            let(:email) { "not_yet_existing@example.com" }

            it "creates a new user with the given email" do
              subject.call
              created_user = Decidim::User.last
              expect(created_user.email).to eq(email)
            end
          end

          context "when the user already exists" do
            let(:email) { existing_user_email }

            before do
              subject.call
            end

            it "doesn't create a new user" do
              expect { subject.call }.to broadcast(:ok)

              polling_officers = Decidim::Votings::PollingOfficer.where(user: existing_user)

              expect(polling_officers.count).to eq 1
            end
          end

          context "when the user hasn't accepted the invitation" do
            before do
              existing_user.invite!
            end

            it "gets the invitation resent" do
              expect { subject.call }.to have_enqueued_job(ActionMailer::DeliveryJob)
            end
          end
        end
      end
    end
  end
end
