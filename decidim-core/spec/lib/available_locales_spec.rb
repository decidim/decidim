# frozen_string_literal: true

require "spec_helper"

# This recreates Decidim inside a module with default vars
# otherwise languages are changed by the test configuration
module LocaleTest
  # rubocop:disable Security/Eval
  eval(File.read(__dir__ + "/../../lib/decidim/core.rb"))
  # rubocop:enable Security/Eval
end

describe "available locales", type: :system do
  let(:languages) do
    %w(en ca de es es-MX es-PY eu fi-pl fi fr gl hu id it nl pl pt pt-BR ru sv tr uk)
  end
  let(:datepicker_file) do
    lambda { |lang|
      __dir__ + "/../../vendor/assets/javascripts/datepicker-locales/foundation-datepicker.#{lang}.js"
    }
  end

  it "has all languages" do
    expect(LocaleTest::Decidim.available_locales).to eq(languages)
  end

  it "has foundation datepicker locales in vendor folder" do
    LocaleTest::Decidim.available_locales.each do |l|
      # english is not necessary for datepicker
      next if l == "en"
      expect(File).to exist(datepicker_file[l])
    end
  end

  # If they are other language-depending files, tests should added here
end
