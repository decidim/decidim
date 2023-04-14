# frozen_string_literal: true

require "yaml"
require "fileutils"

describe "Spellcheck utility" do
  subject { Dir.chdir(test_directory) { [`#{script}`, $?.exitstatus] } } # rubocop:disable Style/SpecialGlobalVars

  let(:output) { subject[0] }
  let(:output_lines) { output.split("\n") }
  let(:exitstatus) { subject[1] }

  let(:config) { YAML.load_file("#{working_dir}/.spelling.yml") }
  let(:script) { "#{working_dir}/.github/run_spelling_check.sh" }

  let(:test_directory) { "/tmp/decidim-spellcheck-utility-test-#{rand(1_000)}" }
  let(:working_dir) { File.expand_path("..", __dir__) }

  before do
    FileUtils.mkdir_p(test_directory)
    FileUtils.mkdir_p("#{test_directory}/decidim-test/config/locales")
    FileUtils.mkdir_p("#{test_directory}/decidim-test/lib")
    FileUtils.mkdir_p("#{test_directory}/docs")
    FileUtils.mkdir_p("#{test_directory}/lib")

    File.write("#{test_directory}/.spelling.yml", YAML.dump(config))
  end

  after do
    FileUtils.rm_r(Dir.glob(test_directory))
  end

  context "when the project contains spelling mistakes" do
    let(:invalid_code) do
      <<~CODE
        # forbidden_string_literal: true

        class Invalid
          # Strings containing parts of forbidden strings such as "parent" should be ignored.
          #{config["forbidden"].keys.map { |k| "# This comment contains #{k} which is forbidden." }.join("\n  ")}
          #{config["forbidden"].keys.map { |k| "# #{k.capitalize} starts the string." }.join("\n  ")}
        end
      CODE
    end
    let(:invalid_doc) do
      <<~DOC
        # Documentation

        Strings containing parts of forbidden strings such as "parent" should be ignored.

        #{config["forbidden"].keys.map { |k| "This line contains #{k} which is forbidden." }.join("\n")}

        #{config["forbidden"].keys.map { |k| "#{k.capitalize} starts the string." }.join("\n")}
      DOC
    end
    let(:invalid_locale) do
      <<~LOCALE
        en:
          hello: Isn't it nice this file doesn't follow the rules?
      LOCALE
    end

    before do
      File.write("#{test_directory}/decidim-test/lib/invalid.rb", invalid_code)
      File.write("#{test_directory}/decidim-test/config/locales/en.yml", invalid_locale)
      File.write("#{test_directory}/docs/documentation.md", invalid_doc)
      File.write("#{test_directory}/lib/invalid.rb", invalid_code) # This should be ignored
    end

    it "returns the correct errors" do
      expect(exitstatus).to be(1)

      invalid_locale_lines = output_lines[0..2]
      expect(invalid_locale_lines[0]).to eq(
        %(::error file=decidim-test/config/locales/en.yml,line=2,col=10,endColumn=15::Use "is not" instead of "isn't".)
      )
      expect(invalid_locale_lines[1]).to eq(
        %(::error file=decidim-test/config/locales/en.yml,line=2,col=34,endColumn=41::Use "does not" instead of "doesn't".)
      )

      start_lines = [5, 5 + config["forbidden"].length]
      invalid_code_lines = output_lines[2..((2 * config["forbidden"].length) + 2)]
      config["forbidden"].each_with_index do |(word, preferred), idx|
        expect(invalid_code_lines[idx]).to eq(
          %(::error file=decidim-test/lib/invalid.rb,line=#{start_lines[0] + idx},col=27,endColumn=#{27 + word.length}::Use "#{preferred}" instead of "#{word}".)
        )
        expect(invalid_code_lines[idx + config["forbidden"].length]).to eq(
          %(::error file=decidim-test/lib/invalid.rb,line=#{start_lines[1] + idx},col=5,endColumn=#{5 + word.length}::Use "#{preferred}" instead of "#{word}".)
        )
      end

      start_lines = [5, 6 + config["forbidden"].length]
      invalid_doc_lines = output_lines[((2 * config["forbidden"].length) + 2)..((4 * config["forbidden"].length) + 2)]
      config["forbidden"].each_with_index do |(word, preferred), idx|
        expect(invalid_doc_lines[idx]).to eq(
          %(::error file=docs/documentation.md,line=#{start_lines[0] + idx},col=20,endColumn=#{20 + word.length}::Use "#{preferred}" instead of "#{word}".)
        )
        expect(invalid_doc_lines[idx + config["forbidden"].length]).to eq(
          %(::error file=docs/documentation.md,line=#{start_lines[1] + idx},col=1,endColumn=#{1 + word.length}::Use "#{preferred}" instead of "#{word}".)
        )
      end

      expect(output).not_to include("::error file=lib/invalid.rb")
    end
  end

  context "when the project does not have any spelling mistakes" do
    let(:code) do
      <<~CODE
        # forbidden_string_literal: true

        class Correct
          # This does not have any spelling mistakes.
        end
      CODE
    end
    let(:doc) do
      <<~DOC
        # Documentation

        Strings containing parts of forbidden strings such as "parent" should be ignored.
      DOC
    end
    let(:invalid_locale) do
      <<~LOCALE
        fi:
          hello: Isn't it nice this file doesn't follow the rules?
      LOCALE
    end

    before do
      File.write("#{test_directory}/decidim-test/lib/correct.rb", code)
      File.write("#{test_directory}/decidim-test/config/locales/fi.yml", invalid_locale)
      File.write("#{test_directory}/docs/documentation.md", doc)
    end

    it "returns the correct status code" do
      expect(exitstatus).to be(0)
    end
  end
end
