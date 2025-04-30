# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    module Admin
      describe CreateElection do
        subject { described_class.new(form) }

        let(:organization) { create(:organization, available_locales: [:en]) }
        let(:current_user) { create(:user, :admin, :confirmed, organization:) }
        let(:participatory_process) { create(:participatory_process, organization:) }
        let(:component) { create(:elections_component, participatory_space: participatory_process) }
        let(:title) { { en: "Election Title" } }
        let(:description) { { en: "Election Description" } }
        let(:start_at) { 1.day.from_now }
        let(:end_at) { 2.days.from_now }
        let(:manual_start) { false }
        let(:uploaded_photos) { [] }
        let(:photos) { [] }
        let(:invalid) { false }

        let(:form) do
          double(
            "Decidim::Elections::Admin::ElectionForm",
            invalid?: invalid,
            current_organization: organization,
            current_component: component,
            current_user:,
            title:,
            description:,
            start_at:,
            end_at:,
            manual_start:,
            results_availability: "after_end",
            photos:,
            add_photos: uploaded_photos
          )
        end

        context "when the form is not valid" do
          let(:invalid) { true }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when everything is ok" do
          let(:election) { Election.last }

          it "creates the election" do
            expect { subject.call }.to change(Election, :count).by(1)
          end

          it "sets attributes" do
            subject.call
            expect(election.title["en"]).to eq("Election Title")
            expect(election.description["en"]).to eq("Election Description")
            expect(election.component).to eq(component)
          end

          it "sets start and end time" do
            subject.call
            expect(election.start_at).to eq(start_at)
            expect(election.end_at).to eq(end_at)
          end

          context "when manual_start is true" do
            let(:manual_start) { true }

            it "does not set times" do
              subject.call
              expect(election.start_at).to be_nil
              expect(election.end_at).to eq(end_at)
            end
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:create!)
              .with(
                Decidim::Elections::Election,
                current_user,
                hash_including(
                  title: title,
                  description: description,
                  start_at:,
                  end_at:,
                  results_availability: "after_end",
                  component:
                ),
                visibility: "all"
              ).and_call_original

            expect { subject.call }.to change(Decidim::ActionLog, :count)
            expect(Decidim::ActionLog.last.version).to be_present
          end

          it "creates a searchable resource" do
            expect { subject.call }.to change(Decidim::SearchableResource, :count).by_at_least(1)
          end

          it_behaves_like "admin creates resource gallery" do
            let(:command) { described_class.new(form) }
            let(:resource_class) { Decidim::Elections::Election }
          end
        end
      end
    end
  end
end
