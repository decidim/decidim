# frozen_string_literal: true

# Note that RSpec also provides `uses_transaction "doesn't run in transaction"`
# but it doesn't work the same way. We want the same database to be used without
# transactions during the tests so that we can test concurrency correctly.
RSpec.shared_context "with concurrency" do
  self.use_transactional_tests = false
  after do
    # Because the transactional tests are disabled, we need to manually clear
    # the tables after the test.
    connection = ActiveRecord::Base.connection
    connection.disable_referential_integrity do
      connection.tables.each do |table_name|
        next if connection.select_value("SELECT COUNT(*) FROM #{table_name}").zero?

        connection.execute("TRUNCATE #{table_name} CASCADE")
      end
    end
  end
end
