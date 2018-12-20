# frozen_string_literal: true

require "i18n/tasks"

describe "I18n sanity" do
  let(:locales) do
    ENV["ENFORCED_LOCALES"].presence || "en"
  end

  let(:i18n) { I18n::Tasks::BaseTask.new(locales: locales.split(",")) }
  let(:missing_keys) { i18n.missing_keys }
  let(:unused_keys) { i18n.unused_keys }

  it "does not have missing keys" do
    expect(missing_keys).to be_empty, "#{missing_keys.inspect} are missing"
  end

  it "does not have unused keys" do
    expect(unused_keys).to be_empty, "#{unused_keys.inspect} are unused"
  end
end
