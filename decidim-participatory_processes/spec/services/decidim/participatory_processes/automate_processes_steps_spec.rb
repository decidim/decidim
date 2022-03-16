# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ParticipatoryProcesses
    describe change_active_stepProcessesSteps do
      describe "#change_active_step" do
        subject { described_class.new }

        let(:organization) { create(:organization) }
        let!(:participatory_process) do
          create(
            :participatory_process,
            organization: organization,
            description: { en: "Description", ca: "Descripció", es: "Descripción" },
            short_description: { en: "Short description", ca: "Descripció curta", es: "Descripción corta" },
            published_at: 2.weeks.ago,
            start_date: 2.weeks.ago,
            end_date: Date.new(2022, 6, 15)
          )
        end

        before do
          allow(Time.zone).to receive(:now).and_return(Time.zone.local(2022, 3, 15, 11, 0, 0))
        end

        context "and there are one step not activated" do
          let!(:step) { create(:participatory_process_step, participatory_process: participatory_process) }

          before { subject.change_active_step }

          it "and active the step" do
            expect(step.reload).to be_active
          end
        end

        context "and there are one step activated" do
          let!(:step) do
            create(:participatory_process_step, participatory_process: participatory_process, active: true,
                                                start_date: Time.zone.local(2022, 3, 15, 10, 0, 0), end_date: Time.zone.local(2022, 3, 15, 11, 0, 0))
          end

          before { subject.change_active_step }

          it "and not active the step" do
            expect(step.reload).to be_active
          end
        end

        context "and there are two steps" do
          let!(:step_one) do
            create(:participatory_process_step, participatory_process: participatory_process,
                                                active: true, start_date: Time.zone.local(2022, 3, 15, 10, 0, 0), end_date: Time.zone.local(2022, 3, 15, 22, 0, 0))
          end
          let!(:step_two) do
            create(:participatory_process_step, participatory_process: participatory_process,
                                                start_date: Time.zone.local(2022, 3, 15, 11, 0, 0), end_date: Time.zone.local(2022, 3, 15, 20, 0, 0))
          end

          before { subject.change_active_step }

          it "active step two" do
            expect(step_one.reload).not_to be_active
            expect(step_two.reload).to be_active
          end
        end

        context "and there are three or more steps" do
          let!(:step_one) do
            create(:participatory_process_step, participatory_process: participatory_process,
                                                active: true, start_date: Time.zone.local(2022, 3, 15, 10, 0, 0), end_date: Time.zone.local(2022, 3, 15, 11, 0, 0))
          end
          let!(:step_two) do
            create(:participatory_process_step, participatory_process: participatory_process,
                                                start_date: Time.zone.local(2022, 3, 15, 11, 0, 0), end_date: Time.zone.local(2022, 3, 15, 20, 0, 0))
          end

          before { subject.change_active_step }

          context "and have the third step with different datetime" do
            let!(:step_three) do
              create(:participatory_process_step, participatory_process: participatory_process,
                                                  start_date: Time.zone.local(2022, 3, 16, 8, 0, 0), end_date: Time.zone.local(2022, 3, 16, 20, 0, 0))
            end

            it "active step two" do
              expect(step_one.reload).not_to be_active
              expect(step_two.reload).to be_active
            end
          end

          context "and have the third step with same date but different time" do
            let!(:step_three) do
              create(:participatory_process_step, participatory_process: participatory_process,
                                                  start_date: Time.zone.local(2022, 3, 15, 11, 30, 0), end_date: Time.zone.local(2022, 3, 15, 20, 0, 0))
            end

            it "active step two" do
              expect(step_one.reload).not_to be_active
              expect(step_two.reload).to be_active
            end
          end

          context "and have the third step with same datetime" do
            let!(:step_three) do
              create(:participatory_process_step, participatory_process: participatory_process,
                                                  start_date: Time.zone.local(2022, 3, 15, 11, 0, 0), end_date: Time.zone.local(2022, 3, 15, 20, 0, 0))
            end

            it "active step two" do
              expect(step_one.reload).not_to be_active
              expect(step_two.reload).to be_active
            end
          end
        end
      end
    end
  end
end
