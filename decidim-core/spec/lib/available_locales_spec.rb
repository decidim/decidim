# frozen_string_literal: true

require "spec_helper"

# This recreates Decidim inside a module with default vars
# otherwise languages are changed by the test configuration
module LocaleTest
  # rubocop:disable Security/Eval
  eval(File.read("#{__dir__}/../../lib/decidim/core.rb"))
  # rubocop:enable Security/Eval
end

describe "available locales", type: :system do
  let(:languages) do
    %w(en bg ar ca cs da de el eo es es-MX es-PY et eu fi-pl fi fr fr-CA ga gl hr hu id is it ja ko lb lt lv mt nl no pl pt pt-BR ro ru sk sl sr sv tr uk vi zh-CN zh-TW)
  end
  let(:datepicker_file) do
    lambda { |lang|
      __dir__ + "/../../vendor/assets/javascripts/datepicker-locales/foundation-datepicker.#{lang}.js"
    }
  end

  it "has all languages" do
    expect(LocaleTest::Decidim.available_locales).to eq(languages)
  end

  LocaleTest::Decidim.available_locales.each do |locale|
    # english is not necessary for datepicker
    next if locale == "en"

    it "has foundation datepicker locales in vendor folder for #{locale}" do
      expect(File).to exist(datepicker_file[locale])
    end
  end

  # If they are other language-depending files, tests should added here
end
