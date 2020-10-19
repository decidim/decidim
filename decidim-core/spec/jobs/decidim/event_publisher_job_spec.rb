# frozen_string_literal: true

require "spec_helper"

describe Decidim::EventPublisherJob do
  subject { described_class }

  shared_examples_for "batch priority" do |priority, enqueues_jobs|
    let(:priority) { priority }

    context "when the priority is #{priority}" do
      if enqueues_jobs == true
        it "enqueues the jobs" do
          expect(Decidim::EmailNotificationGeneratorJob).to receive(:perform_later)
          expect(Decidim::NotificationGeneratorJob).to receive(:perform_later)

          subject
        end
      else
        it "doesn't enqueue the jobs" do
          expect(Decidim::EmailNotificationGeneratorJob).not_to receive(:perform_later)
          expect(Decidim::NotificationGeneratorJob).not_to receive(:perform_later)

          subject
        end
      end
    end
  end

  describe "queue" do
    it "is queued to events" do
      expect(subject.queue_name).to eq "events"
    end
  end

  describe "perform" do
    subject do
      described_class.perform_now(event_name, data)
    end

    let(:event_name) { "some_event" }
    let(:priority) { :batch }
    let(:data) do
      {
        resource: resource,
        priority: priority
      }
    end

    context "when the resource is publicable" do
      let(:resource) { build(:dummy_resource) }

      context "when it is published" do
        before do
          resource.published_at = Time.current
        end

        it "enqueues the jobs" do
          expect(Decidim::EmailNotificationGeneratorJob).to receive(:perform_later)
          expect(Decidim::NotificationGeneratorJob).to receive(:perform_later)

          subject
        end

        context "and batch notifications is enabled" do
          before do
            Decidim.config.batch_email_notifications_enabled = true
          end

          after do
            Decidim.config.batch_email_notifications_enabled = false
          end

          context "and priority is batch" do
            it "enqueues the jobs except email" do
              expect(Decidim::EmailNotificationGeneratorJob).not_to receive(:perform_later)
              expect(Decidim::NotificationGeneratorJob).to receive(:perform_later)

              subject
            end

            context "and force_send is true" do
              before do
                data[:force_send] = true
              end

              it "enqueues the jobs" do
                expect(Decidim::EmailNotificationGeneratorJob).to receive(:perform_later)
                expect(Decidim::NotificationGeneratorJob).to receive(:perform_later)

                subject
              end
            end
          end
        end
      end

      context "when it is not published" do
        before do
          resource.published_at = nil
        end

        it "doesn't enqueue the jobs" do
          expect(Decidim::EmailNotificationGeneratorJob).not_to receive(:perform_later)
          expect(Decidim::NotificationGeneratorJob).not_to receive(:perform_later)

          subject
        end

        context "and batch notifications is enabled" do
          before do
            Decidim.config.batch_email_notifications_enabled = true
          end

          after do
            Decidim.config.batch_email_notifications_enabled = false
          end

          [:batch, :now].each do |priority|
            it_behaves_like "batch priority", priority, false
          end
        end

        context "when #force_send is true" do
          before do
            data[:force_send] = true
          end

          it "enqueues the jobs without checking if the resource is published" do
            expect(Decidim::EmailNotificationGeneratorJob).to receive(:perform_later)
            expect(Decidim::NotificationGeneratorJob).to receive(:perform_later)

            subject
          end

          context "and batch notifications is enabled" do
            before do
              Decidim.config.batch_email_notifications_enabled = true
            end

            after do
              Decidim.config.batch_email_notifications_enabled = false
            end

            [:batch, :now].each do |priority|
              it_behaves_like "batch priority", priority, true
            end
          end
        end
      end
    end

    context "when there's a component" do
      let(:resource) { build(:dummy_resource) }

      context "when it is published" do
        before do
          resource.published_at = Time.current
          resource.component.published_at = Time.current
        end

        it "enqueues the jobs" do
          expect(Decidim::EmailNotificationGeneratorJob).to receive(:perform_later)
          expect(Decidim::NotificationGeneratorJob).to receive(:perform_later)

          subject
        end

        context "and batch notifications is enabled" do
          before do
            Decidim.config.batch_email_notifications_enabled = true
          end

          after do
            Decidim.config.batch_email_notifications_enabled = false
          end

          context "and priority is batch" do
            it "enqueues the jobs except email" do
              expect(Decidim::EmailNotificationGeneratorJob).not_to receive(:perform_later)
              expect(Decidim::NotificationGeneratorJob).to receive(:perform_later)

              subject
            end
          end

          context "and priority is now" do
            let(:priority) { :now }

            it "enqueues the jobs" do
              expect(Decidim::EmailNotificationGeneratorJob).to receive(:perform_later)
              expect(Decidim::NotificationGeneratorJob).to receive(:perform_later)

              subject
            end
          end
        end
      end

      context "when it is not published" do
        before do
          resource.published_at = Time.current
          resource.component.published_at = nil
        end

        it "doesn't enqueue the jobs" do
          expect(Decidim::EmailNotificationGeneratorJob).not_to receive(:perform_later)
          expect(Decidim::NotificationGeneratorJob).not_to receive(:perform_later)

          subject
        end

        context "and batch notifications is enabled" do
          before do
            Decidim.config.batch_email_notifications_enabled = true
          end

          after do
            Decidim.config.batch_email_notifications_enabled = false
          end

          [:batch, :now].each do |priority|
            it_behaves_like "batch priority", priority, false
          end
        end
      end
    end

    context "when there's a participatory space" do
      let(:resource) { build(:dummy_resource) }

      context "when it is published" do
        before do
          resource.published_at = Time.current
          resource.component.participatory_space.published_at = Time.current
        end

        it "enqueues the jobs" do
          expect(Decidim::EmailNotificationGeneratorJob).to receive(:perform_later)
          expect(Decidim::NotificationGeneratorJob).to receive(:perform_later)

          subject
        end

        context "and batch notifications is enabled" do
          before do
            Decidim.config.batch_email_notifications_enabled = true
          end

          after do
            Decidim.config.batch_email_notifications_enabled = false
          end

          context "and priority is batch" do
            it "enqueues the jobs except email" do
              expect(Decidim::EmailNotificationGeneratorJob).not_to receive(:perform_later)
              expect(Decidim::NotificationGeneratorJob).to receive(:perform_later)

              subject
            end
          end

          context "and priority is now" do
            let(:priority) { :now }

            it "enqueues the jobs" do
              expect(Decidim::EmailNotificationGeneratorJob).to receive(:perform_later)
              expect(Decidim::NotificationGeneratorJob).to receive(:perform_later)

              subject
            end
          end
        end
      end

      context "when it is not published" do
        before do
          resource.published_at = Time.current
          resource.component.participatory_space.published_at = nil
        end

        it "doesn't enqueue the jobs" do
          expect(Decidim::EmailNotificationGeneratorJob).not_to receive(:perform_later)
          expect(Decidim::NotificationGeneratorJob).not_to receive(:perform_later)

          subject
        end

        context "and batch notifications is enabled" do
          before do
            Decidim.config.batch_email_notifications_enabled = true
          end

          after do
            Decidim.config.batch_email_notifications_enabled = false
          end

          [:batch, :now].each do |priority|
            it_behaves_like "batch priority", priority, false
          end
        end
      end

      context "when the resource is a component" do
        let(:resource) { build(:component) }

        it "enqueues the jobs" do
          expect(Decidim::EmailNotificationGeneratorJob).to receive(:perform_later)
          expect(Decidim::NotificationGeneratorJob).to receive(:perform_later)

          subject
        end

        context "and batch notifications is enabled" do
          before do
            Decidim.config.batch_email_notifications_enabled = true
          end

          after do
            Decidim.config.batch_email_notifications_enabled = false
          end

          context "and priority is batch" do
            it "enqueues the jobs except email" do
              expect(Decidim::EmailNotificationGeneratorJob).not_to receive(:perform_later)
              expect(Decidim::NotificationGeneratorJob).to receive(:perform_later)

              subject
            end
          end

          context "and priority is now" do
            let(:priority) { :now }

            it "enqueues the jobs" do
              expect(Decidim::EmailNotificationGeneratorJob).to receive(:perform_later)
              expect(Decidim::NotificationGeneratorJob).to receive(:perform_later)

              subject
            end
          end
        end

        context "when it is not published" do
          let(:resource) { build(:component, :unpublished) }

          it "doesn't enqueue the jobs" do
            expect(Decidim::EmailNotificationGeneratorJob).not_to receive(:perform_later)
            expect(Decidim::NotificationGeneratorJob).not_to receive(:perform_later)

            subject
          end

          context "and batch notifications is enabled" do
            before do
              Decidim.config.batch_email_notifications_enabled = true
            end

            after do
              Decidim.config.batch_email_notifications_enabled = false
            end

            [:batch, :now].each do |priority|
              it_behaves_like "batch priority", priority, false
            end
          end
        end
      end

      context "when the resource is a participatory space" do
        let(:resource) { build(:participatory_process) }

        context "and batch notifications is enabled" do
          before do
            Decidim.config.batch_email_notifications_enabled = true
          end

          after do
            Decidim.config.batch_email_notifications_enabled = false
          end

          context "and priority is batch" do
            it "enqueues the jobs except email" do
              expect(Decidim::EmailNotificationGeneratorJob).not_to receive(:perform_later)
              expect(Decidim::NotificationGeneratorJob).to receive(:perform_later)

              subject
            end
          end

          context "and priority is now" do
            let(:priority) { :now }

            it "enqueues the jobs" do
              expect(Decidim::EmailNotificationGeneratorJob).to receive(:perform_later)
              expect(Decidim::NotificationGeneratorJob).to receive(:perform_later)

              subject
            end
          end
        end

        context "when it is not published" do
          let(:resource) { build(:participatory_process, :unpublished) }

          it "doesn't enqueue the jobs" do
            expect(Decidim::EmailNotificationGeneratorJob).not_to receive(:perform_later)
            expect(Decidim::NotificationGeneratorJob).not_to receive(:perform_later)

            subject
          end

          context "and batch notifications is enabled" do
            before do
              Decidim.config.batch_email_notifications_enabled = true
            end

            after do
              Decidim.config.batch_email_notifications_enabled = false
            end

            [:batch, :now].each do |priority|
              it_behaves_like "batch priority", priority, false
            end
          end
        end
      end
    end
  end
end
