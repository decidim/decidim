# frozen_string_literal: true

require "spec_helper"

require "./db/data/20261009120001_reset_conference_registrations_counters_of_decidim_conferences_registration_types"

describe ResetConferenceRegistrationsCountersOfDecidimConferencesRegistrationTypes do
  let(:migrator) do
    described_class.new.tap do |m|
      m.verbose = false
    end
  end

  describe "#up" do
    let(:registration_type) { create(:registration_type) }

    it "resets conference_registrations_count to the number of registrations" do
      create_list(:conference_registration, 2, registration_type:)

      # The counter cache can be out of sync with the actual rows.
      # rubocop:disable-next Rails/SkipsModelValidations
      registration_type.update_column(:conference_registrations_count, 0)

      migrator.migrate(:up)

      expect(registration_type.reload.conference_registrations_count).to eq(2)
    end

    it "locks the registration type row before counting and keeps the lock until the counter is written" do
      create_list(:conference_registration, 2, registration_type:)

      queries = capture_queries { migrator.migrate(:up) }

      lock = queries.index { |sql| sql.include?("FOR UPDATE") }
      count = queries.index { |sql| sql.include?("SELECT COUNT(*) FROM \"decidim_conferences_conference_registrations\"") }
      write = queries.index { |sql| sql.include?("UPDATE \"decidim_conferences_registration_types\" SET \"conference_registrations_count\"") }

      expect(lock).not_to be_nil
      expect(count).not_to be_nil
      expect(write).not_to be_nil
      expect(lock).to be < count
      expect(lock).to be < write
    end

    context "when there is more than one registration type" do
      include_context "with concurrency"

      it "commits each type separately, releasing its lock before processing the next one" do
        create_list(:registration_type, 2)

        queries = capture_queries { migrator.migrate(:up) }

        locks = queries.each_index.select { |index| queries[index].include?("FOR UPDATE") }
        writes = queries.each_index.select { |index| queries[index].include?("UPDATE \"decidim_conferences_registration_types\"") }
        commits = queries.each_index.select { |index| queries[index] == "COMMIT" }

        expect(locks.length).to eq(2)
        expect(writes.length).to eq(2)
        expect(commits.length).to eq(2)

        # The first type's lock is released by its own commit before the second type is locked.
        expect(locks.first).to be < writes.first
        expect(writes.first).to be < commits.first
        expect(commits.first).to be < locks.last
      end
    end

    context "when a registration is created while the backfill runs" do
      include_context "with concurrency"

      it "does not overwrite the concurrent counter-cache increment" do
        create_list(:conference_registration, 2, registration_type:)

        ready = Queue.new
        start = Queue.new

        thread = Thread.new do
          ActiveRecord::Base.connection_pool.with_connection do
            ready.push(true)
            start.pop
            create(:conference_registration, registration_type: Decidim::Conferences::RegistrationType.find(registration_type.id))
          end
        end

        ready.pop
        start.push(true)

        # The migration's outer transaction is disabled, so each type is processed in its own
        # transaction and the row lock is held until that type's counter is committed. The
        # concurrent insert can only increment the counter afterwards, on top of the value written
        # by the backfill.
        migrator.migrate(:up)
        thread.join

        expect(registration_type.reload.conference_registrations_count).to eq(3)
      end
    end
  end

  def capture_queries
    queries = []
    subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") { |_, _, _, _, data| queries << data[:sql] }
    yield
    queries
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber)
  end
end
