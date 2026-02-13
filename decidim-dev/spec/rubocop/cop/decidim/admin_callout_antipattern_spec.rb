# frozen_string_literal: true

require "rubocop"
require "rubocop/rspec/support"
require "decidim/dev/rubocop/cop/decidim/admin_callout_antipattern"

RSpec.describe RuboCop::Cop::Decidim::AdminCalloutAntipattern, :config do
  include RuboCop::RSpec::ExpectOffense

  it "registers an offense for single-word callouts" do
    expect_offense(<<~RUBY)
      expect(page).to have_admin_callout("successfully")
                                         ^^^^^^^^^^^^^^ Anti-pattern detected: avoid generic single-word or very short text in have_admin_callout. Use the full admin flash message, e.g. 'Meeting successfully published'.
    RUBY
  end

  it "registers an offense for very short callouts" do
    expect_offense(<<~RUBY)
      expect(page).to have_admin_callout("ok")
                                         ^^^^ Anti-pattern detected: avoid generic single-word or very short text in have_admin_callout. Use the full admin flash message, e.g. 'Meeting successfully published'.
    RUBY
  end

  it "accepts descriptive callouts" do
    expect_no_offenses(<<~RUBY)
      expect(page).to have_admin_callout("Template copied successfully.")
    RUBY
  end

  it "registers an offense for multi-word short callouts" do
    expect_offense(<<~RUBY)
      expect(page).to have_admin_callout("Hello world")
                                         ^^^^^^^^^^^^^ Anti-pattern detected: avoid generic single-word or very short text in have_admin_callout. Use the full admin flash message, e.g. 'Meeting successfully published'.
    RUBY
  end

  it "registers an offense when punctuation strips to short text" do
    expect_offense(<<~RUBY)
      expect(page).to have_admin_callout("Success!!!")
                                         ^^^^^^^^^^^^ Anti-pattern detected: avoid generic single-word or very short text in have_admin_callout. Use the full admin flash message, e.g. 'Meeting successfully published'.
    RUBY
  end

  it "accepts callouts with exactly 12 characters" do
    expect_no_offenses(<<~RUBY)
      expect(page).to have_admin_callout("Hello my world")
    RUBY
  end

  it "registers an offense for callouts with multiple spaces" do
    expect_offense(<<~RUBY)
      expect(page).to have_admin_callout("Hello   world")
                                         ^^^^^^^^^^^^^^^ Anti-pattern detected: avoid generic single-word or very short text in have_admin_callout. Use the full admin flash message, e.g. 'Meeting successfully published'.
    RUBY
  end

  it "registers an offense for empty string callouts" do
    expect_offense(<<~RUBY)
      expect(page).to have_admin_callout("")
                                         ^^ Anti-pattern detected: avoid generic single-word or very short text in have_admin_callout. Use the full admin flash message, e.g. 'Meeting successfully published'.
    RUBY
  end

  it "registers an offense for whitespace-only callouts" do
    expect_offense(<<~RUBY)
      expect(page).to have_admin_callout("   ")
                                         ^^^^^ Anti-pattern detected: avoid generic single-word or very short text in have_admin_callout. Use the full admin flash message, e.g. 'Meeting successfully published'.
    RUBY
  end

  it "registers an offense for nil callouts" do
    expect_offense(<<~RUBY)
      expect(page).to have_admin_callout(nil)
                                         ^^^ Anti-pattern detected: avoid generic single-word or very short text in have_admin_callout. Use the full admin flash message, e.g. 'Meeting successfully published'.
    RUBY
  end
end
