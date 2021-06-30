# frozen_string_literal: true

module Decidim
  module MigrationTestGroup
    extend ActiveSupport::Concern

    included do
      subject { migration }

      let(:migration) do |example|
        struct = migration_for(example)
        require Rails.root.join(struct.filename)
        struct.name.constantize.new
      end

      around do |example|
        ActiveRecord::Migration.suppress_messages do
          example.run
        end
      end
    end

    private

    def migration_name_for(example)
      group = example.metadata[:example_group]
      group = group[:parent_example_group] while group[:parent_example_group]
      group[:description]
    end

    def migration_for(example)
      migration_name = migration_name_for(example)
      struct = migrations.find { |m| m.name == migration_name }
      raise NameError, "Unexisting migration: `#{migration_name}`" unless struct

      struct
    end

    def migrations
      ActiveRecord::MigrationContext.new(
        [Rails.root.join("db/migrate")]
      ).migrations
    end
  end
end

RSpec.configure do |config|
  config.include Decidim::MigrationTestGroup, type: :migration
end
