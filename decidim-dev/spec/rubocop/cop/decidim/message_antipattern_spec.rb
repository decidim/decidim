# frozen_string_literal: true

require "rubocop"
require "rubocop/rspec/support"
require "decidim/dev/rubocop/cop/decidim/message_antipattern"

RSpec.describe RuboCop::Cop::Decidim::MessageAntipattern, :config do
  include RuboCop::RSpec::ExpectOffense

  it "registers an offense for single-word callouts" do
    expect_offense(<<~RUBY)
      expect(page).to have_callout("successfully")
                                   ^^^^^^^^^^^^^^ Anti-pattern detected: avoid generic single-word text in have_callout/have_admin_callout/have_content. Use the full admin flash message, e.g. 'Meeting successfully published'. Exception: when used inside `within` blocks (e.g., for checking `.label` elements).
    RUBY
  end

  it "registers an offense for very short callouts" do
    expect_offense(<<~RUBY)
      expect(page).to have_callout("ok")
                                   ^^^^ Anti-pattern detected: avoid generic single-word text in have_callout/have_admin_callout/have_content. Use the full admin flash message, e.g. 'Meeting successfully published'. Exception: when used inside `within` blocks (e.g., for checking `.label` elements).
    RUBY
  end

  it "accepts descriptive callouts" do
    expect_no_offenses(<<~RUBY)
      expect(page).to have_callout("Template copied successfully.")
    RUBY
  end

  it "accepts multi-word callouts" do
    expect_no_offenses(<<~RUBY)
      expect(page).to have_callout("Hello world")
    RUBY
  end

  it "accepts single words not in the anti-pattern list" do
    expect_no_offenses(<<~RUBY)
      expect(page).to have_callout("Success!!!")
    RUBY
  end

  it "accepts callouts with multiple spaces" do
    expect_no_offenses(<<~RUBY)
      expect(page).to have_callout("Hello   world")
    RUBY
  end

  it "registers an offense for empty string callouts" do
    expect_offense(<<~RUBY)
      expect(page).to have_callout("")
                                   ^^ Anti-pattern detected: avoid generic single-word text in have_callout/have_admin_callout/have_content. Use the full admin flash message, e.g. 'Meeting successfully published'. Exception: when used inside `within` blocks (e.g., for checking `.label` elements).
    RUBY
  end

  it "registers an offense for whitespace-only callouts" do
    expect_offense(<<~RUBY)
      expect(page).to have_callout("   ")
                                   ^^^^^ Anti-pattern detected: avoid generic single-word text in have_callout/have_admin_callout/have_content. Use the full admin flash message, e.g. 'Meeting successfully published'. Exception: when used inside `within` blocks (e.g., for checking `.label` elements).
    RUBY
  end

  it "registers an offense for nil callouts" do
    expect_offense(<<~RUBY)
      expect(page).to have_callout(nil)
                                   ^^^ Anti-pattern detected: avoid generic single-word text in have_callout/have_admin_callout/have_content. Use the full admin flash message, e.g. 'Meeting successfully published'. Exception: when used inside `within` blocks (e.g., for checking `.label` elements).
    RUBY
  end

  it "registers an offense for single-word content" do
    expect_offense(<<~RUBY)
      expect(page).to have_content("successfully")
                                   ^^^^^^^^^^^^^^ Anti-pattern detected: avoid generic single-word text in have_callout/have_admin_callout/have_content. Use the full admin flash message, e.g. 'Meeting successfully published'. Exception: when used inside `within` blocks (e.g., for checking `.label` elements).
    RUBY
  end

  it "registers an offense for single-word admin callouts" do
    expect_offense(<<~RUBY)
      expect(page).to have_admin_callout("successfully")
                                         ^^^^^^^^^^^^^^ Anti-pattern detected: avoid generic single-word text in have_callout/have_admin_callout/have_content. Use the full admin flash message, e.g. 'Meeting successfully published'. Exception: when used inside `within` blocks (e.g., for checking `.label` elements).
    RUBY
  end

  it "registers an offense for short admin callouts" do
    expect_offense(<<~RUBY)
      expect(page).to have_admin_callout("ok")
                                         ^^^^ Anti-pattern detected: avoid generic single-word text in have_callout/have_admin_callout/have_content. Use the full admin flash message, e.g. 'Meeting successfully published'. Exception: when used inside `within` blocks (e.g., for checking `.label` elements).
    RUBY
  end

  it "accepts descriptive admin callouts" do
    expect_no_offenses(<<~RUBY)
      expect(page).to have_admin_callout("Template copied successfully.")
    RUBY
  end

  it "registers an offense for short content" do
    expect_offense(<<~RUBY)
      expect(page).to have_content("ok")
                                   ^^^^ Anti-pattern detected: avoid generic single-word text in have_callout/have_admin_callout/have_content. Use the full admin flash message, e.g. 'Meeting successfully published'. Exception: when used inside `within` blocks (e.g., for checking `.label` elements).
    RUBY
  end

  it "accepts descriptive content" do
    expect_no_offenses(<<~RUBY)
      expect(page).to have_content("Template copied successfully.")
    RUBY
  end

  it "ignores content checks inside within blocks" do
    expect_no_offenses(<<~RUBY)
      within(".filters") do
        expect(page).to have_content("ok")
      end
    RUBY
  end
end
