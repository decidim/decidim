# frozen_string_literal: true

require "i18n/tasks"

describe "I18n sanity" do
  let(:locales) do
    ENV["ENFORCED_LOCALES"].present? ? ENV["ENFORCED_LOCALES"].split(",") : [:en]
  end

  let(:i18n) { I18n::Tasks::BaseTask.new(locales: locales) }
  let(:missing_keys) { i18n.missing_keys }
  let(:unused_keys) { i18n.unused_keys }

  it "does not have missing keys" do
    expect(missing_keys).to be_empty, "#{missing_keys.inspect} are missing"
  end

  it "does not have unused keys" do
    expect(unused_keys).to be_empty, "#{unused_keys.inspect} are unused"
  end

  unless ENV["SKIP_NORMALIZATION"]
    it "is normalized" do
      previous_locale_hashes = locale_hashes
      i18n.normalize_store!
      new_locale_hashes = locale_hashes

      expect(previous_locale_hashes).to eq(new_locale_hashes),
                                        "Please normalize your locale files with `bundle exec i18n-tasks normalize`"
    end
  end

  def locale_hashes
    Dir.glob("decidim-*/config/locales/**/*.yml").inject({}) do |results, file|
      md5 = Digest::MD5.file(file).hexdigest
      results.merge(file => md5)
    end
  end
end
