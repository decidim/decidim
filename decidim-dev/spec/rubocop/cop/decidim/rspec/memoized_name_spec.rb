# frozen_string_literal: true

require "rubocop"
require "rubocop/rspec/support"
require "decidim/dev/rubocop/cop/decidim/rspec/memoized_name"

RSpec.describe RuboCop::Cop::Decidim::RSpec::MemoizedName, :config do
  include RuboCop::RSpec::ExpectOffense

  it "accepts valid name" do
    expect_no_offenses(<<~RUBY)
      let(:valid_name) { "value" }
    RUBY
  end

  described_class::RESERVED_NAMES.each do |klass, names|
    names.each do |name|
      context "with #{name}" do
        it "registers an offense for very short callouts" do
          expect_offense(<<~RUBY)
            let(:#{name}) { "value" }
                ^#{"^" * name.length} Do not use reserved names as memoized variable names in specs: #{name}. Reserved by: #{klass}.
          RUBY
        end
      end
    end
  end
end
