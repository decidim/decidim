# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Votings
    module Admin
      describe CreateVoting do
        subject { described_class.new(form) }

        let(:organization) { create :organization, available_locales: [:en, :ca, :es], default_locale: :en }
        let(:user) { create :user, :admin, :confirmed, organization: }

        let(:form) do
          double(
            invalid?: invalid,
            title: { en: "The voting space title" },
            description: { en: "The voting space description" },
            start_time:,
            end_time:,
            slug:,
            scope:,
            current_user: user,
            current_organization: organization,
            banner_image: nil,
            introductory_image: nil,
            promoted:,
            voting_type:,
            census_contact_information:,
            show_check_census:
          )
        end

        let(:invalid) { false }
        let(:title) { { en: "The voting space title" } }
        let(:description) { { en: "The voting space description" } }
        let(:start_time) { 1.day.from_now }
        let(:end_time) { start_time + 1.month }
        let(:slug) { "voting-slug" }
        let(:scope) { create :scope, organization: }
        let(:promoted) { true }
        let(:voting_type) { "online" }
        let(:census_contact_information) { nil }
        let(:show_check_census) { true }

        let(:voting) { Decidim::Votings::Voting.last }

        it "creates the voting" do
          expect { subject.call }.to change { Decidim::Votings::Voting.count }.by(1)
        end

        it "broadcasts ok" do
          expect { subject.call }.to broadcast(:ok)
        end

        it "stores the given data" do
          subject.call
          expect(translated(voting.title)).to eq title[:en]
          expect(translated(voting.description)).to eq description[:en]
          expect(voting.start_time).to be_within(1.second).of start_time
          expect(voting.end_time).to be_within(1.second).of end_time
          expect(voting.slug).to eq slug
          expect(voting.scope).to eq scope
          expect(voting.organization).to eq organization
          expect(voting.promoted).to eq promoted
          expect(voting.voting_type).to eq voting_type
          expect(voting.show_check_census).to eq show_check_census
        end

        it "traces the action", versioning: true do
          expect(Decidim.traceability)
            .to receive(:create)
            .with(
              Decidim::Votings::Voting,
              user,
              kind_of(Hash)
            )
            .and_call_original

          expect { subject.call }.to change(Decidim::ActionLog, :count)
          action_log = Decidim::ActionLog.last
          expect(action_log.version).to be_present
          expect(action_log.version.event).to eq "create"
        end

        context "when the form is not valid" do
          let(:invalid) { true }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end
      end
    end
  end
end
