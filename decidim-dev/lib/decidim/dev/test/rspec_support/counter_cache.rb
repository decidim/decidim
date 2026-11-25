# frozen_string_literal: true

# Checks that a `counter_cache` column is updated atomically, as required for
# new counter logic by the security guidelines in `.ai/security.md`. The
# counter cache must survive concurrent writes without losing increments.
#
# The host group must define:
# - `counter_parent`: the record holding the counter cache column, freshly
#   created so that its counter starts at zero
# - `counter_column`: the name of the counter cache column
# - `counter_children`: an array of callables accepting the parent record and
#   creating a single child record associated to it. Each callable receives
#   its own copy of the parent, loaded inside the worker thread, mirroring
#   concurrent requests which never share ActiveRecord instances. Any other
#   record needed by a callable must be resolved while building the callables
#   (e.g. stored in a local variable) and not from within them, so that the
#   worker threads never race on the RSpec memoization.
RSpec.shared_examples "a concurrency safe counter cache" do
  include_context "with concurrency"

  it "does not lose increments when the children are created concurrently" do
    parent = counter_parent
    column = counter_column
    children = counter_children

    ready = Queue.new
    start = Queue.new

    threads = children.map do |create_child|
      Thread.new do
        ready.push(true)
        # Keep every thread idle until all of them are ready, in order to
        # maximize the contention on the counter cache column.
        start.pop
        ActiveRecord::Base.connection_pool.with_connection do
          create_child.call(parent.class.unscoped.find(parent.id))
        end
      end
    end

    children.size.times { ready.pop }
    children.size.times { start.push(true) }
    threads.each(&:join)

    expect(parent.reload.public_send(column)).to eq(children.size)
  end
end
