# frozen_string_literal: true

require "spec_helper"

describe Decidim::OpenDataJob do
  subject { described_class }

  let(:organization) { create(:organization) }

  describe "perform" do
    before do
      organization.open_data_files.purge
    end

    it "uploads the generated file" do
      expect { subject.perform_now(organization) }.to change { organization.open_data_files.attached? }.from(false).to(true)
    end

    context "when exporting a resource twice" do
      let(:resource) { "users" }
      let(:filename) { organization.open_data_file_path(resource) }
      let!(:first_user) { create(:user, :confirmed, organization:, name: "First exported user") }

      def resource_files
        organization.reload.open_data_files.select { |file| file.blob.filename.to_s == filename }
      end

      it "replaces the previous file with the refreshed one" do
        subject.perform_now(organization, resource)
        first_file = resource_files.first
        expect(first_file.blob.download).to include(first_user.name)

        second_user = create(:user, :confirmed, organization:, name: "Second exported user")
        subject.perform_now(organization, resource)

        expect(resource_files.size).to eq(1)
        refreshed_file = resource_files.first
        expect(refreshed_file.id).not_to eq(first_file.id)

        content = refreshed_file.blob.download
        expect(content).to include(first_user.name)
        expect(content).to include(second_user.name)
      end

      it "purges the uploaded replacement blob when publication rolls back" do
        # rubocop:disable-next RSpec/AnyInstance
        allow_any_instance_of(Decidim::Organization).to receive(:with_lock).and_raise(ActiveRecord::Deadlocked)

        subject.perform_now(organization, resource)

        # `retry_on ActiveRecord::Deadlocked` reschedules the job, so the exception does
        # not reach `perform_now`; the replacement blob must still be cleaned up.
        expect(resource_files).to be_empty
        expect(ActiveStorage::Blob.where(filename:)).to be_empty
      end

      context "when another job publishes the same resource while this job is exporting" do
        it "removes the duplicate created by the other job" do
          # Simulate the other job attaching its file after this job loaded the attachments,
          # so the preloaded collection is stale when the cleanup runs.
          # rubocop:disable-next RSpec/AnyInstance
          allow_any_instance_of(Decidim::OpenDataExporter).to receive(:export).and_wrap_original do |original, *args|
            Decidim::Organization.find(organization.id).open_data_files.attach(
              io: StringIO.new("concurrent export"), filename:
            )
            original.call(*args)
          end

          subject.perform_now(organization, resource)

          expect(resource_files.size).to eq(1)
          expect(resource_files.first.blob.download).to include(first_user.name)
        end
      end

      context "when two jobs export the same resource concurrently" do
        include_context "with concurrency"

        it "leaves a single file for the resource" do
          # Force both jobs to load their attachment snapshot before either publishes,
          # so the example exercises overlapping publication rather than a sequential schedule.
          gate = Queue.new
          mutex = Mutex.new
          arrivals = 0

          # rubocop:disable-next RSpec/AnyInstance
          allow_any_instance_of(Decidim::OpenDataExporter).to receive(:export).and_wrap_original do |original, *args|
            last = mutex.synchronize { arrivals += 1 } == 2
            gate << true if last
            Timeout.timeout(10) { gate.pop } unless last
            original.call(*args)
          end

          errors = []
          threads = 2.times.map do
            Thread.new do
              ActiveRecord::Base.connection_pool.with_connection do
                described_class.perform_now(organization, resource)
              rescue StandardError => e
                errors << e
                # Release the other worker if this one never reached the barrier.
                gate << true
              end
            end
          end
          threads.each(&:join)

          expect(errors).to be_empty
          # `retry_on ActiveRecord::Deadlocked` reschedules a retry instead of raising
          # in the thread, so assert that no worker needed one.
          open_data_retries = ActiveJob::Base.queue_adapter.enqueued_jobs.select { |job| job["job_class"] == "Decidim::OpenDataJob" }
          expect(open_data_retries).to be_empty
          expect(resource_files.size).to eq(1)
        end
      end
    end
  end

  it "deletes the temporary file after finishing the job" do
    organization = create(:organization)

    expect(FileUtils).to receive(:rm_f) do |path|
      expect(path.to_s).to match(%r{tmp/.*})
    end
    described_class.perform_now(organization)
  end
end
