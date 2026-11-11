# frozen_string_literal: true

require "spec_helper"

require "./db/data/20260724121933_reset_budget_counter_cache"

describe ResetBudgetCounterCache do
  let(:migrator) do
    described_class.new.tap do |m|
      m.verbose = false
    end
  end

  describe "#up" do
    let(:budget) { create(:budget) }

    it "resets projects_count to the number of non-trashed projects" do
      create_list(:project, 2, budget:)
      create(:project, budget:).destroy

      # The counter cache can be out of sync with the actual rows.
      # rubocop:disable-next Rails/SkipsModelValidations
      budget.update_column(:projects_count, 0)

      migrator.migrate(:up)

      expect(budget.reload.projects_count).to eq(2)
    end

    it "locks the budget row before counting and keeps the lock until the counter is written" do
      create_list(:project, 2, budget:)

      queries = capture_queries do
        ActiveRecord::Base.transaction { migrator.migrate(:up) }
      end

      lock = queries.index { |sql| sql.include?("FOR UPDATE") }
      count = queries.index { |sql| sql.include?("SELECT COUNT(*) FROM \"decidim_budgets_projects\"") }
      write = queries.index { |sql| sql.include?("UPDATE \"decidim_budgets_budgets\" SET \"projects_count\"") }

      expect(lock).not_to be_nil
      expect(count).not_to be_nil
      expect(write).not_to be_nil
      expect(lock).to be < count
      expect(lock).to be < write
    end

    context "when a project is created while the backfill runs" do
      include_context "with concurrency"

      it "does not overwrite the concurrent counter-cache increment" do
        create_list(:project, 2, budget:)

        ready = Queue.new
        start = Queue.new

        thread = Thread.new do
          ActiveRecord::Base.connection_pool.with_connection do
            ready.push(true)
            start.pop
            create(:project, budget: Decidim::Budgets::Budget.find(budget.id))
          end
        end

        ready.pop
        start.push(true)

        # Data migrations run inside a transaction, so the lock taken on the budget row is held
        # until the counter is written. The concurrent insert can only increment the counter
        # afterwards, on top of the value written by the backfill.
        ActiveRecord::Base.transaction { migrator.migrate(:up) }
        thread.join

        expect(budget.reload.projects_count).to eq(3)
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
