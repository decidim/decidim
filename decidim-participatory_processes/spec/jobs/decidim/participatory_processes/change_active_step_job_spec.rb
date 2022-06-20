# frozen_string_literal: true

require "spec_helper"

describe Decidim::ParticipatoryProcesses::ChangeActiveStepJob do
  subject { described_class }

  describe "queue" do
    it "is queued to events" do
      expect(subject.queue_name).to eq "default"
    end
  end

  describe "perform" do
    let(:organization) { create(:organization) }
    let!(:participatory_process) do
      create(
        :participatory_process,
        organization: organization,
        description: { en: "Description", ca: "Descripció", es: "Descripción" },
        short_description: { en: "Short description", ca: "Descripció curta", es: "Descripción corta" },
        published_at: Date.new(2022, 3, 1),
        start_date: Date.new(2022, 3, 1),
        end_date: Date.new(2022, 3, 15)
      )
    end

    before do
      allow(Time.zone).to receive(:now).and_return(Time.zone.local(2022, 3, 15, 11, 0, 0))
    end

    context "with one step" do
      context "when not activated but enters period" do
        let!(:step) { create(:participatory_process_step, participatory_process: participatory_process) }

        before { subject.perform_now }

        it "the step is activated" do
          expect(step.reload).to be_active
        end
      end

      context "and one step is activated but finishes now" do
        let!(:step) do
          create(:participatory_process_step, participatory_process: participatory_process, active: true,
                                              end_date: Time.zone.local(2022, 3, 15, 10, 59, 59))
        end

        before { subject.perform_now }

        it "stays active" do
          expect(step.reload).to be_active
        end
      end
    end

    context "with two overlaping steps" do
      let!(:step_one) do
        create(
          :participatory_process_step,
          participatory_process: participatory_process,
          active: true,
          start_date: Time.zone.local(2022, 3, 15, 10, 0, 0),
          end_date: Time.zone.local(2022, 3, 15, 22, 0, 0)
        )
      end
      let!(:step_two) do
        create(
          :participatory_process_step,
          participatory_process: participatory_process,
          start_date: Time.zone.local(2022, 3, 15, 10, 30, 0),
          end_date: Time.zone.local(2022, 3, 15, 20, 0, 0)
        )
      end

      before { subject.perform_now }

      it "activates the first step with early end date" do
        expect(step_one.reload).not_to be_active
        expect(step_two.reload).to be_active
      end
    end

    context "with three steps all with dates" do
      let!(:step_one) do
        create(:participatory_process_step, participatory_process: participatory_process,
                                            active: true, start_date: Time.zone.local(2022, 3, 15, 10, 0, 0), end_date: Time.zone.local(2022, 3, 15, 10, 59, 59))
      end
      let!(:step_two) do
        create(:participatory_process_step, participatory_process: participatory_process,
                                            start_date: Time.zone.local(2022, 3, 15, 11, 0, 0), end_date: Time.zone.local(2022, 3, 15, 20, 0, 0))
      end

      context "and have the third step with different datetime" do
        let!(:step_three) do
          create(:participatory_process_step, participatory_process: participatory_process,
                                              start_date: Time.zone.local(2022, 3, 16, 8, 0, 0), end_date: Time.zone.local(2022, 3, 16, 20, 0, 0))
        end

        before { subject.perform_now }

        it "activates step two" do
          expect(step_one.reload).not_to be_active
          expect(step_two.reload).to be_active
          expect(step_three.reload).not_to be_active
        end
      end

      context "and have the third step with same date but different time" do
        let!(:step_three) do
          create(:participatory_process_step, participatory_process: participatory_process,
                                              start_date: Time.zone.local(2022, 3, 15, 11, 30, 0), end_date: Time.zone.local(2022, 3, 15, 20, 0, 0))
        end

        before { subject.perform_now }

        it "activates step two" do
          expect(step_one.reload).not_to be_active
          expect(step_two.reload).to be_active
          expect(step_three.reload).not_to be_active
        end
      end

      context "and have the third step with same date and time as step two" do
        let!(:step_three) do
          create(:participatory_process_step, participatory_process: participatory_process,
                                              start_date: Time.zone.local(2022, 3, 15, 11, 0, 0), end_date: Time.zone.local(2022, 3, 15, 20, 0, 0))
        end

        before { subject.perform_now }

        it "activates step two" do
          expect(step_one.reload).not_to be_active
          expect(step_two.reload).to be_active
          expect(step_three.reload).not_to be_active
        end
      end

      context "and two was active and three was overlaping but now two has finished and three continues" do
        let!(:step_one) do
          create(
            :participatory_process_step,
            participatory_process: participatory_process,
            start_date: Time.zone.local(2022, 3, 15, 10, 0, 0),
            end_date: Time.zone.local(2022, 3, 15, 10, 59, 59)
          )
        end
        let!(:step_two) do
          create(
            :participatory_process_step,
            participatory_process: participatory_process,
            active: true,
            start_date: Time.zone.local(2022, 3, 15, 8, 0, 0),
            end_date: Time.zone.local(2022, 3, 15, 10, 0, 0)
          )
        end
        let!(:step_three) do
          create(
            :participatory_process_step,
            participatory_process: participatory_process,
            start_date: Time.zone.local(2022, 3, 14, 11, 0, 0),
            end_date: Time.zone.local(2022, 3, 15, 20, 0, 0)
          )
        end

        before { subject.perform_now }

        it "activates step three" do
          expect(step_one.reload).not_to be_active
          expect(step_two.reload).not_to be_active
          expect(step_three.reload).to be_active
        end
      end

      context "and all phases has finished" do
        let!(:step_one) do
          create(
            :participatory_process_step,
            participatory_process: participatory_process,
            start_date: Time.zone.local(2022, 3, 15, 10, 0, 0),
            end_date: Time.zone.local(2022, 3, 15, 10, 59, 59)
          )
        end
        let!(:step_two) do
          create(
            :participatory_process_step,
            participatory_process: participatory_process,
            active: true,
            start_date: Time.zone.local(2022, 3, 15, 8, 0, 0),
            end_date: Time.zone.local(2022, 3, 15, 10, 0, 0)
          )
        end
        let!(:step_three) do
          create(
            :participatory_process_step,
            participatory_process: participatory_process,
            start_date: Time.zone.local(2022, 3, 14, 10, 0, 0),
            end_date: Time.zone.local(2022, 3, 15, 10, 59, 59)
          )
        end

        before { subject.perform_now }

        it "still activate step three" do
          expect(step_one.reload).not_to be_active
          expect(step_two.reload).not_to be_active
          expect(step_three.reload).to be_active
        end
      end

      context "and third step start_date > today" do
        let!(:step_three) do
          create(
            :participatory_process_step,
            participatory_process: participatory_process,
            start_date: Time.zone.local(2022, 3, 16, 10, 0, 0),
            end_date: Time.zone.local(2022, 3, 17, 10, 59, 59)
          )
        end

        before { subject.perform_now }

        it "still activate step two" do
          expect(step_one.reload).not_to be_active
          expect(step_two.reload).to be_active
          expect(step_three.reload).not_to be_active
        end
      end
    end

    context "with two steps but not all have dates" do
      context "when first is active without dates and second enters now" do
        let!(:step_one) do
          create(
            :participatory_process_step,
            participatory_process: participatory_process,
            active: true,
            start_date: nil,
            end_date: nil
          )
        end
        let!(:step_two) do
          create(
            :participatory_process_step,
            participatory_process: participatory_process,
            start_date: Time.zone.local(2022, 3, 15, 11, 0, 0),
            end_date: Time.zone.local(2022, 3, 15, 20, 0, 0)
          )
        end

        before { subject.perform_now }

        it "activates step two" do
          expect(step_one.reload).not_to be_active
          expect(step_two.reload).to be_active
        end
      end

      context "when first is active with dates and finished and second does not have dates" do
        let!(:step_one) do
          create(
            :participatory_process_step,
            participatory_process: participatory_process,
            active: true,
            start_date: Time.zone.local(2022, 3, 14, 11, 0, 0),
            end_date: Time.zone.local(2022, 3, 15, 10, 59, 0)
          )
        end
        let!(:step_two) do
          create(
            :participatory_process_step,
            participatory_process: participatory_process,
            start_date: nil,
            end_date: nil
          )
        end

        before { subject.perform_now }

        it "step one stays active" do
          expect(step_one.reload).to be_active
          expect(step_two.reload).not_to be_active
        end
      end
    end
  end
end
