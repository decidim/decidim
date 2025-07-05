# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    module Admin
      describe ProcessCensus do
        subject { described_class.new(form, election) }

        let(:organization) { create(:organization, available_locales: [:en]) }
        let(:current_user) { create(:user, :admin, :confirmed, organization:) }
        let(:participatory_process) { create(:participatory_process, organization:) }
        let(:component) { create(:elections_component, participatory_space: participatory_process) }
        let(:election) { create(:election, component:, census_manifest: :token_csv) }

        let(:form) do
          double(
            "Decidim::Elections::Admin::CensusForm",
            invalid?: invalid,
            current_user:,
            census_settings:,
            remove_all: false,
            file: true,
            data: []
          )
        end

        let(:invalid) { false }
        let(:census_settings) { { "verification_handlers" => ["dummy"] } }

        describe "#call" do
          context "when the form is invalid" do
            let(:invalid) { true }

            it { expect { subject.call }.to broadcast(:invalid) }
          end

          context "when the form is valid" do
            it "updates the census manifest and settings" do
              expect do
                subject.call
              end.to change { election.reload.census_settings }.to(census_settings)
            end

            it "broadcasts :ok" do
              subject.call
              expect(subject).to broadcast(:ok)
            end
          end
        end

        describe "#run_after_hooks" do
          let(:command_class) { class_double("Decidim::Elections::Admin::Censuses::TokenCsv") }

          before do
            stub_const("Decidim::Elections::Admin::Censuses::TokenCsv", command_class)
            allow(command_class).to receive(:call)
          end

          it "calls the after_update_command" do
            subject.run_after_hooks
            expect(command_class).to have_received(:call).with(form, election)
          end

          context "when after_update_command is nil" do
            before do
              allow(election.census).to receive(:after_update_command).and_return(nil)
            end

            it "does not call the after_update_command" do
              expect { subject.run_after_hooks }.not_to raise_error
            end
          end
        end

        describe "#attributes" do
          it "returns the correct attributes" do
            expect(subject.attributes).to eq({ census_manifest: election.census.name, census_settings: })
          end
        end
      end
    end
  end
end
