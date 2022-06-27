# frozen_string_literal: true

require "spec_helper"

module Decidim::Budgets
  describe OrderReminderGenerator do
    subject { described_class.new }

    let(:manifest) do
      double(
        settings: double(
          attributes: {
            reminder_times: double(default: intervals)
          }
        )
      )
    end
    let(:intervals) { [2.hours, 1.week, 2.weeks] }
    let(:organization) { create(:organization) }
    let(:component) { create(:component, organization:, manifest_name: "budgets") }
    let(:budget) { create(:budget, component:, total_budget: 100_000) }
    let(:project) { create(:project, budget:, budget_amount: 90_000) }
    let(:user) { create(:user, organization:) }

    before do
      allow(Decidim.reminders_registry).to receive(:for).with(:orders).and_return(manifest)
    end

    describe "#generate" do
      context "when there is an order created yesterday" do
        let!(:order) { create(:order, :with_projects, user:, budget:, created_at: 1.day.ago) }

        it "sends reminder" do
          expect(Decidim::Budgets::SendVoteReminderJob).to receive(:perform_later)

          expect { subject.generate }.to change(Decidim::Reminder, :count).by(1)
        end

        context "and another order in different budget" do
          let(:another_budget) { create(:budget, component:, total_budget: 100_000) }
          let!(:another_order) { create(:order, :with_projects, user:, budget: another_budget, created_at: 1.day.ago) }

          it "sends reminder with two records" do
            expect(Decidim::Budgets::SendVoteReminderJob).to receive(:perform_later)

            expect { subject.generate }.to change(Decidim::Reminder, :count).by(1)
            expect(Decidim::Reminder.first.records.count).to eq(2)
          end
        end

        context "and order is checked out" do
          before do
            order.update(checked_out_at: Time.current)
          end

          it "does not send reminder" do
            expect(Decidim::Budgets::SendVoteReminderJob).not_to receive(:perform_later)

            expect { subject.generate }.not_to change(Decidim::Reminder, :count)
          end
        end

        context "and reminder exists" do
          let!(:reminder) { create(:reminder, user:, component:) }

          it "sends existing reminder" do
            expect(Decidim::Budgets::SendVoteReminderJob).to receive(:perform_later)

            expect { subject.generate }.not_to change(Decidim::Reminder, :count)
          end

          context "and record has been already added to the reminder" do
            let(:reminder_record) { create(:reminder_record, reminder:, remindable: order) }

            before { reminder.records << reminder_record }

            it "sends existing reminder but does not re-add record to the reminder" do
              expect(Decidim::Budgets::SendVoteReminderJob).to receive(:perform_later).twice

              expect { subject.generate }.not_to change(reminder.records, :count)
              expect { subject.generate }.not_to change(Decidim::Reminder, :count)
            end

            context "with confirmed order" do
              before { order.update!(checked_out_at: 1.minute.ago) }

              it "does not send reminder" do
                expect(Decidim::Budgets::SendVoteReminderJob).not_to receive(:perform_later)

                subject.generate
              end
            end
          end

          context "and user has been already reminded" do
            let!(:reminder_delivery) { create(:reminder_delivery, reminder:, created_at: 1.hour.ago) }

            it "does not send reminder" do
              expect(Decidim::Budgets::SendVoteReminderJob).not_to receive(:perform_later)
              expect { subject.generate }.not_to change(Decidim::Reminder, :count)
            end
          end
        end
      end

      context "when there is an order created more than week ago" do
        let!(:order) { create(:order, :with_projects, user:, budget:, created_at: 8.days.ago) }
        let(:reminder) { create(:reminder, user:, component:) }

        context "and user has been reminded once" do
          let!(:reminder_delivery) { create(:reminder_delivery, reminder:, created_at: order.created_at + intervals[0]) }

          it "sends reminder again" do
            expect(Decidim::Budgets::SendVoteReminderJob).to receive(:perform_later)

            subject.generate
          end
        end
      end

      context "when user has two orders" do
        let(:another_budget) { create(:budget, component:, total_budget: 100_000) }
        let(:first_order) { create(:order, :with_projects, user:, budget:, created_at: 9.days.ago) }
        let(:recent_order) { create(:order, :with_projects, user:, budget: another_budget, created_at: 8.days.ago) }

        context "and user has been reminded once" do
          let(:reminder) { create(:reminder, user:, component:) }
          let!(:reminder_record) { create(:reminder_record, reminder:, remindable: first_order) }
          let!(:another_reminder_record) { create(:reminder_record, reminder:, remindable: recent_order) }
          let!(:reminder_delivery) { create(:reminder_delivery, reminder:, created_at: first_order.created_at + intervals[0]) }

          context "when recent order is checked out" do
            before { recent_order.update!(checked_out_at: 1.minute.ago) }

            it "marks recent record as completed and sends reminder about first order" do
              expect(Decidim::Budgets::SendVoteReminderJob).to receive(:perform_later)

              expect { subject.generate }.to change(reminder.records.active, :count)
                .to(1)
                .and change(reminder.records.completed, :count).to(1)
              expect(reminder.records.active.first.remindable).to eq(first_order)
            end
          end

          context "when first order is checked out" do
            before { first_order.update!(checked_out_at: 1.minute.ago) }

            it "marks first record as completed and sends reminder about recent order" do
              expect(Decidim::Budgets::SendVoteReminderJob).to receive(:perform_later)

              expect { subject.generate }.to change(reminder.records.active, :count)
                .to(1)
                .and change(reminder.records.completed, :count).to(1)
              expect(reminder.records.active.first.remindable).to eq(recent_order)
            end
          end

          context "when first order is deleted" do
            before { first_order.destroy! }

            it "marks first record as deleted and sends reminder about recent order" do
              expect(Decidim::Budgets::SendVoteReminderJob).to receive(:perform_later)

              expect { subject.generate }.to change(reminder.records.active, :count)
                .to(1)
                .and change(reminder.records.deleted, :count).to(1)
              expect(reminder.records.active.first.remindable).to eq(recent_order)
            end
          end

          context "when recent order is deleted" do
            before { recent_order.destroy! }

            it "marks recent record as deleted and sends reminder about first order" do
              expect(Decidim::Budgets::SendVoteReminderJob).to receive(:perform_later)

              expect { subject.generate }.to change(reminder.records.deleted, :count)
                .to(1)
                .and change(reminder.records.deleted, :count).to(1)
              expect(reminder.records.active.first.remindable).to eq(first_order)
            end
          end
        end
      end

      context "when there is multiple orders created day ago and one order is checked out" do
        let(:users) { create_list(:user, 6, organization:) }
        let!(:orders) { users.map { |u| create(:order, :with_projects, user: u, budget:, created_at: 1.day.ago) } }

        before do
          orders[0].update!(checked_out_at: Time.current)
        end

        it "sends reminders" do
          expect(Decidim::Budgets::SendVoteReminderJob).to receive(:perform_later).exactly(5).times
          subject.generate
        end
      end
    end
  end
end
