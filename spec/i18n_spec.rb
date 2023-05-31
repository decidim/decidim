# frozen_string_literal: true

require "i18n/tasks"

describe "I18n sanity" do
  let(:locales) do
    ENV["ENFORCED_LOCALES"].presence || "en"
  end

  let(:i18n) { I18n::Tasks::BaseTask.new(locales: locales.split(",")) }
  let(:missing_keys) { i18n.missing_keys }
  let(:unused_keys) { i18n.unused_keys }
  let(:non_normalized_paths) { i18n.non_normalized_paths }
  let(:inconsistent_interpolations) { i18n.inconsistent_interpolations }

  it "correct Norwegian locale keys should be surrounded by quotation marks" do
    # otherwise psych evaluates `no:` to `false`
    # see https://makandracards.com/makandra/24809-yaml-keys-like-yes-or-no-evaluate-to-true-and-false
    i18n = I18n::Tasks::BaseTask.new(locales: "no")
    forest = i18n.data_forest(["no"])
    stats = i18n.forest_stats(forest)
    expect(stats[:locales]).to eq("no")
  end

  it "does not have missing keys" do
    expect(missing_keys).to be_empty,
                            "Missing #{missing_keys.leaves.count} i18n keys, please run `ENFORCED_LOCALES=#{locales} bundle exec i18n-tasks missing --locales #{locales}' to show them"
  end

  it "does not have unused keys" do
    expect(unused_keys).to be_empty,
                           "#{unused_keys.leaves.count} unused i18n keys, please run `bundle exec i18n-tasks unused --locales #{locales}' to show them"
  end

  unless ENV["SKIP_NORMALIZATION"]
    it "is normalized" do
      error_message = "The following files need to be normalized:\n" \
                      "#{non_normalized_paths.map { |path| "  #{path}" }.join("\n")}\n" \
                      "Please run `bundle exec i18n-tasks normalize --locales #{locales}` to fix them"

      expect(non_normalized_paths).to be_empty, error_message
    end
  end

  it "does not have inconsistent interpolations" do
    error_message = "#{inconsistent_interpolations.leaves.count} i18n keys have inconsistent interpolations.\n" \
                    "Please run `bundle exec i18n-tasks check-consistent-interpolations --locales #{locales}` to show them"
    expect(inconsistent_interpolations).to be_empty, error_message
  end
end
