# frozen_string_literal: true

require "i18n/tasks"

RSpec.shared_examples_for "I18n sanity" do
  let(:i18n) { I18n::Tasks::BaseTask.new(locales: [I18n.default_locale]) }
  let(:missing_keys) { i18n.missing_keys }
  let(:unused_keys) { i18n.unused_keys }

  it "does not have missing keys" do
    expect(missing_keys).to be_empty,
                            "Missing #{missing_keys.leaves.count} i18n keys, run `i18n-tasks missing` to show them"
  end

  it "does not have unused keys" do
    expect(unused_keys).to be_empty,
                           "#{unused_keys.leaves.count} unused i18n keys, run `i18n-tasks unused` to show them"
  end

  it "is normalized" do
    previous_locale_hashes = locale_hashes
    i18n.normalize_store!
    new_locale_hashes = locale_hashes

    expect(previous_locale_hashes).to eq(new_locale_hashes),
                                      "Please normalize your locale files with `i18n-tasks normalize`"
  end

  def locale_hashes
    Dir.glob("config/locales/**/*.yml").inject({}) do |results, file|
      md5 = Digest::MD5.file(file).hexdigest
      results.merge(file => md5)
    end
  end
end
