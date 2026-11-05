# frozen_string_literal: true

require "spec_helper"

describe Decidim::ParticipatoryProcesses::ChangeActivePhaseJob do
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
        organization:,
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

    context "with one phase" do
      context "when not activated but enters period" do
        let!(:phase) { create(:participatory_process_phase, participatory_process:) }

        before { subject.perform_now }

        it "the phase is activated" do
          expect(phase.reload).to be_active
        end
      end

      context "and one phase is activated but finishes now" do
        let!(:phase) do
          create(:participatory_process_phase, participatory_process:, active: true,
                                               end_date: Time.zone.local(2022, 3, 15, 10, 59, 59))
        end

        before { subject.perform_now }

        it "stays active" do
          expect(phase.reload).to be_active
        end
      end
    end

    context "with two overlapping phases" do
      let!(:phase_one) do
        create(
          :participatory_process_phase,
          participatory_process:,
          active: true,
          start_date: Time.zone.local(2022, 3, 15, 10, 0, 0),
          end_date: Time.zone.local(2022, 3, 15, 22, 0, 0)
        )
      end
      let!(:phase_two) do
        create(
          :participatory_process_phase,
          participatory_process:,
          start_date: Time.zone.local(2022, 3, 15, 10, 30, 0),
          end_date: Time.zone.local(2022, 3, 15, 20, 0, 0)
        )
      end

      before { subject.perform_now }

      it "activates the first phase with early end date" do
        expect(phase_one.reload).not_to be_active
        expect(phase_two.reload).to be_active
      end
    end

    context "with three phases all with dates" do
      let!(:phase_one) do
        create(:participatory_process_phase, participatory_process:,
                                             active: true, start_date: Time.zone.local(2022, 3, 15, 10, 0, 0), end_date: Time.zone.local(2022, 3, 15, 10, 59, 59))
      end
      let!(:phase_two) do
        create(:participatory_process_phase, participatory_process:,
                                             start_date: Time.zone.local(2022, 3, 15, 11, 0, 0), end_date: Time.zone.local(2022, 3, 15, 20, 0, 0))
      end

      context "and have the third phase with different datetime" do
        let!(:phase_three) do
          create(:participatory_process_phase, participatory_process:,
                                               start_date: Time.zone.local(2022, 3, 16, 8, 0, 0), end_date: Time.zone.local(2022, 3, 16, 20, 0, 0))
        end

        before { subject.perform_now }

        it "activates phase two" do
          expect(phase_one.reload).not_to be_active
          expect(phase_two.reload).to be_active
          expect(phase_three.reload).not_to be_active
        end
      end

      context "and have the third phase with same date but different time" do
        let!(:phase_three) do
          create(:participatory_process_phase, participatory_process:,
                                               start_date: Time.zone.local(2022, 3, 15, 11, 30, 0), end_date: Time.zone.local(2022, 3, 15, 20, 0, 0))
        end

        before { subject.perform_now }

        it "activates phase two" do
          expect(phase_one.reload).not_to be_active
          expect(phase_two.reload).to be_active
          expect(phase_three.reload).not_to be_active
        end
      end

      context "and have the third phase with same date and time as phase two" do
        let!(:phase_three) do
          create(:participatory_process_phase, participatory_process:,
                                               start_date: Time.zone.local(2022, 3, 15, 11, 0, 0), end_date: Time.zone.local(2022, 3, 15, 20, 0, 0))
        end

        before { subject.perform_now }

        it "activates phase two" do
          expect(phase_one.reload).not_to be_active
          expect(phase_two.reload).to be_active
          expect(phase_three.reload).not_to be_active
        end
      end

      context "and two was active and three was overlapping but now two has finished and three continues" do
        let!(:phase_one) do
          create(
            :participatory_process_phase,
            participatory_process:,
            start_date: Time.zone.local(2022, 3, 15, 10, 0, 0),
            end_date: Time.zone.local(2022, 3, 15, 10, 59, 59)
          )
        end
        let!(:phase_two) do
          create(
            :participatory_process_phase,
            participatory_process:,
            active: true,
            start_date: Time.zone.local(2022, 3, 15, 8, 0, 0),
            end_date: Time.zone.local(2022, 3, 15, 10, 0, 0)
          )
        end
        let!(:phase_three) do
          create(
            :participatory_process_phase,
            participatory_process:,
            start_date: Time.zone.local(2022, 3, 14, 11, 0, 0),
            end_date: Time.zone.local(2022, 3, 15, 20, 0, 0)
          )
        end

        before { subject.perform_now }

        it "activates phase three" do
          expect(phase_one.reload).not_to be_active
          expect(phase_two.reload).not_to be_active
          expect(phase_three.reload).to be_active
        end
      end

      context "and all phases has finished" do
        let!(:phase_one) do
          create(
            :participatory_process_phase,
            participatory_process:,
            start_date: Time.zone.local(2022, 3, 15, 10, 0, 0),
            end_date: Time.zone.local(2022, 3, 15, 10, 59, 59)
          )
        end
        let!(:phase_two) do
          create(
            :participatory_process_phase,
            participatory_process:,
            active: true,
            start_date: Time.zone.local(2022, 3, 15, 8, 0, 0),
            end_date: Time.zone.local(2022, 3, 15, 10, 0, 0)
          )
        end
        let!(:phase_three) do
          create(
            :participatory_process_phase,
            participatory_process:,
            start_date: Time.zone.local(2022, 3, 14, 10, 0, 0),
            end_date: Time.zone.local(2022, 3, 15, 10, 59, 59)
          )
        end

        before { subject.perform_now }

        it "still activate phase three" do
          expect(phase_one.reload).not_to be_active
          expect(phase_two.reload).not_to be_active
          expect(phase_three.reload).to be_active
        end
      end

      context "and third phase start_date > today" do
        let!(:phase_three) do
          create(
            :participatory_process_phase,
            participatory_process:,
            start_date: Time.zone.local(2022, 3, 16, 10, 0, 0),
            end_date: Time.zone.local(2022, 3, 17, 10, 59, 59)
          )
        end

        before { subject.perform_now }

        it "still activate phase two" do
          expect(phase_one.reload).not_to be_active
          expect(phase_two.reload).to be_active
          expect(phase_three.reload).not_to be_active
        end
      end
    end

    context "with two phases but not all have dates" do
      context "when first is active without dates and second enters now" do
        let!(:phase_one) do
          create(
            :participatory_process_phase,
            participatory_process:,
            active: true,
            start_date: nil,
            end_date: nil
          )
        end
        let!(:phase_two) do
          create(
            :participatory_process_phase,
            participatory_process:,
            start_date: Time.zone.local(2022, 3, 15, 11, 0, 0),
            end_date: Time.zone.local(2022, 3, 15, 20, 0, 0)
          )
        end

        before { subject.perform_now }

        it "activates phase two" do
          expect(phase_one.reload).not_to be_active
          expect(phase_two.reload).to be_active
        end
      end

      context "when first is active with dates and finished and second does not have dates" do
        let!(:phase_one) do
          create(
            :participatory_process_phase,
            participatory_process:,
            active: true,
            start_date: Time.zone.local(2022, 3, 14, 11, 0, 0),
            end_date: Time.zone.local(2022, 3, 15, 10, 59, 0)
          )
        end
        let!(:phase_two) do
          create(
            :participatory_process_phase,
            participatory_process:,
            start_date: nil,
            end_date: nil
          )
        end

        before { subject.perform_now }

        it "phase one stays active" do
          expect(phase_one.reload).to be_active
          expect(phase_two.reload).not_to be_active
        end
      end
    end

    describe "with traceability logging" do
      let!(:phase_one) do
        create(
          :participatory_process_phase,
          participatory_process:,
          active: true,
          start_date: Time.zone.local(2022, 3, 10, 10, 0, 0),
          end_date: Time.zone.local(2022, 3, 14, 10, 59, 59)
        )
      end
      let!(:phase_two) do
        create(
          :participatory_process_phase,
          participatory_process:,
          start_date: Time.zone.local(2022, 3, 15, 11, 0, 0),
          end_date: Time.zone.local(2022, 3, 20, 20, 0, 0)
        )
      end

      describe "when user is missing" do
        it "logs activation in activity log" do
          expect { subject.perform_now }
            .to change(Decidim::ActionLog, :count).by(1)

          activation_log = Decidim::ActionLog.last
          expect(activation_log.action).to eq("system_activate")
          expect(activation_log.resource_id).to eq(phase_two.id)
          expect(activation_log.user).to be_nil
          expect(activation_log.user_id).to be_nil
          expect(activation_log.user_type).to be_nil
          expect(activation_log.organization).to eq(organization)
        end
      end

      context "when the log cannot be created" do
        before do
          allow(Decidim::ActionLogger).to receive(:log_system).and_raise(ActiveRecord::StatementInvalid)
        end

        it "rolls back the phase changes" do
          expect { subject.perform_now }.to raise_error(ActiveRecord::StatementInvalid)
          expect(phase_one.reload).to be_active
          expect(phase_two.reload).not_to be_active
        end
      end
    end

    describe "when the phase has already been activated by a concurrent execution" do
      let!(:previous_phase) do
        create(
          :participatory_process_phase,
          participatory_process:,
          start_date: Time.zone.local(2022, 3, 10, 10, 0, 0),
          end_date: Time.zone.local(2022, 3, 14, 10, 59, 59)
        )
      end
      let!(:phase) do
        create(
          :participatory_process_phase,
          participatory_process:,
          start_date: Time.zone.local(2022, 3, 15, 11, 0, 0),
          end_date: Time.zone.local(2022, 3, 20, 20, 0, 0)
        )
      end

      it "reloads the phase and does not log the phase change again" do
        expect(phase).not_to be_active

        # Simulate another execution activating the phase after this one loaded it
        Decidim::ParticipatoryProcessPhase.find(phase.id).update!(active: true)

        expect do
          described_class.new.send(:activate_phase, phase, previous_phase)
        end.not_to change(Decidim::ActionLog, :count)

        expect(phase).to be_active
      end
    end
  end
end
