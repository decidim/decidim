# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    module Admin
      module Censuses
        describe TokenCsv do
          subject { described_class.new(form, election) }

          let(:organization) { create(:organization, available_locales: [:en]) }
          let(:current_user) { create(:user, :admin, :confirmed, organization:) }
          let(:participatory_process) { create(:participatory_process, organization:) }
          let(:component) { create(:elections_component, participatory_space: participatory_process) }
          let(:election) { create(:election, component:) }

          let(:data) { [%w(user1@example.com token1), %w(user2@example.com token2)] }
          let(:form) do
            double(
              "Decidim::Elections::Admin::Censuses::TokenCsvForm",
              invalid?: invalid, remove_all:, file:, data:
            )
          end

          let(:invalid) { false }
          let(:remove_all) { false }
          let(:file) { true }

          describe "#call" do
            context "when the form is invalid" do
              let(:invalid) { true }

              it { expect { subject.call }.to broadcast(:invalid) }
            end

            context "when remove_all is true but no census is set" do
              let(:remove_all) { true }

              before { allow(election).to receive(:census).and_return(nil) }

              it { expect { subject.call }.to broadcast(:invalid) }
            end

            context "when remove_all is true and census exists" do
              let(:remove_all) { true }

              before do
                election.update!(census_manifest: :token_csv)
                election.reload
                create(:voter, election:, data: { email: "user1@example.com", token: "token1" })
              end

              it "deletes all voters" do
                expect { subject.call }.to change { election.voters.count }.from(1).to(0)
              end

              it "broadcasts :ok" do
                subject.call
                expect(subject).to broadcast(:ok)
              end
            end

            context "when file is not present" do
              let(:file) { nil }

              it { expect { subject.call }.to broadcast(:invalid) }
            end

            context "when data is blank" do
              let(:data) { [] }

              it { expect { subject.call }.to broadcast(:invalid) }
            end

            context "when everything is valid" do
              it do
                expect { subject.call }.to change { election.voters.count }.by(2).and broadcast(:ok)

                emails = election.voters.map { |v| v.data["email"] }
                expect(emails).to include("user1@example.com", "user2@example.com")
              end
            end
          end
        end
      end
    end
  end
end
