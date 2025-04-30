# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    module Admin
      describe UpdateElection do
        subject { described_class.new(form, election) }

        let(:organization) { create(:organization, available_locales: [:en]) }
        let(:current_user) { create(:user, :admin, :confirmed, organization:) }
        let(:participatory_process) { create(:participatory_process, organization:) }
        let(:component) { create(:elections_component, participatory_space: participatory_process) }
        let(:election) { create(:election, component:) }

        let(:title) { { en: "Updated title" } }
        let(:description) { { en: "Updated description" } }
        let(:start_at) { 1.day.from_now }
        let(:end_at) { 2.days.from_now }
        let(:manual_start) { false }
        let(:uploaded_photos) { [] }
        let(:current_photos) { [] }
        let(:invalid) { false }

        let(:form) do
          double(
            "Decidim::Elections::Admin::ElectionForm",
            invalid?: invalid,
            current_user:,
            current_organization: organization,
            title:,
            description:,
            start_at:,
            end_at:,
            manual_start:,
            results_availability: "after_end",
            photos: current_photos,
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
          it "updates the election" do
            subject.call
            election.reload
            expect(election.title["en"]).to eq title[:en]
            expect(election.description["en"]).to eq description[:en]
          end

          it "sets times when manual_start is false" do
            subject.call
            election.reload
            expect(election.start_at.to_i).to eq start_at.to_i
            expect(election.end_at.to_i).to eq end_at.to_i
          end

          context "when manual_start is true" do
            let(:manual_start) { true }

            it "clears start and end times" do
              subject.call
              election.reload
              expect(election.start_at).to be_nil
              expect(election.end_at).to be_nil
            end
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:update!)
              .with(
                election,
                current_user,
                hash_including(
                  title:,
                  description:,
                  results_availability: "after_end"
                )
              ).and_call_original

            expect { subject.call }.to change(Decidim::ActionLog, :count)
            expect(Decidim::ActionLog.last.version).to be_present
          end

          it_behaves_like "admin manages resource gallery" do
            let!(:resource) { election }
            let(:resource_class) { Decidim::Elections::Election }
            let(:command) { described_class.new(form, resource) }
          end
        end
      end
    end
  end
end
