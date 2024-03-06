# frozen_string_literal: true

# Note that RSpec also provides `uses_transaction` but it needs to be specific
# with the name of the method which can easily break and the concurrency tests
# will anyways pass when run with the transactional mode. We want the same
# database to be used without transactions during the tests so that we can test
# concurrency correctly.
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
