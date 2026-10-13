# frozen_string_literal: true

require "spec_helper"

require "./db/data/20260727181538_reset_questionnaire_counters"

describe ResetQuestionnaireCounters do
  let(:migrator) do
    described_class.new.tap do |m|
      m.verbose = false
    end
  end

  describe "#up" do
    let(:questionnaire) { create(:questionnaire) }

    it "resets responses_count to the number of responses" do
      create_list(:response, 2, questionnaire:)

      # The counter cache can be out of sync with the actual rows.
      # rubocop:disable-next Rails/SkipsModelValidations
      questionnaire.update_column(:responses_count, 0)

      migrator.migrate(:up)

      expect(questionnaire.reload.responses_count).to eq(2)
    end

    it "locks the questionnaire row before counting and keeps the lock until the counter is written" do
      create_list(:response, 2, questionnaire:)

      queries = capture_queries { migrator.migrate(:up) }

      lock = queries.index { |sql| sql.include?("FOR UPDATE") }
      count = queries.index { |sql| sql.include?("SELECT COUNT(*) FROM \"decidim_forms_responses\"") }
      write = queries.index { |sql| sql.include?("UPDATE \"decidim_forms_questionnaires\" SET \"responses_count\"") }

      expect(lock).not_to be_nil
      expect(count).not_to be_nil
      expect(write).not_to be_nil
      expect(lock).to be < count
      expect(lock).to be < write
    end

    context "when a response is created while the backfill runs" do
      include_context "with concurrency"

      it "does not overwrite the concurrent counter-cache increment" do
        create_list(:response, 2, questionnaire:)

        ready = Queue.new
        start = Queue.new

        thread = Thread.new do
          ActiveRecord::Base.connection_pool.with_connection do
            ready.push(true)
            start.pop
            create(:response, questionnaire: Decidim::Forms::Questionnaire.find(questionnaire.id))
          end
        end

        ready.pop
        start.push(true)

        # The lock taken by `with_lock` is held until the counter is written, so the concurrent
        # insert can only increment the counter afterwards, on top of the value written by the
        # backfill.
        ActiveRecord::Base.transaction { migrator.migrate(:up) }
        thread.join

        expect(questionnaire.reload.responses_count).to eq(3)
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
