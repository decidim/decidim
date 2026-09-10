# frozen_string_literal: true

require "spec_helper"

describe "rake decidim:shakapacker:install", type: :task do
  let(:npm_dependencies) { %w(@decidim/browserslist-config @decidim/core @decidim/webpacker) }
  let(:npm_dev_dependencies) { %w(@decidim/dev @decidim/eslint-config @decidim/prettier-config @decidim/stylelint-config) }

  it "preloads the Rails environment" do
    expect(task.prerequisites).to include "environment"
  end

  it "have changed the app's package.json file" do
    package_json = Rails.root.join("package.json")
    FileUtils.rm(package_json)

    task.execute

    package_json_content = JSON.parse(File.read(package_json))
    expect(package_json_content["dependencies"].keys).to match_array(npm_dependencies)
    expect(package_json_content["devDependencies"].keys).to match_array(npm_dev_dependencies)
  end

  context "when NPM install fails" do
    let(:local_npm_dependencies) { npm_dependencies.map { |dep| dep.sub(%r{\A@decidim/}, "./packages/") } }
    let(:npm_command) { "npm i --save-prod #{local_npm_dependencies.join(" ")}" }
    let(:main) { TOPLEVEL_BINDING.eval("self") }

    before do
      # Prevent actual system calls for these specs
      allow(main).to receive(:system).and_return(true)
    end

    it "retries the command" do
      attempts = 0
      allow(main).to receive(:system).with("cd #{Rails.root} && #{npm_command}") do
        attempts += 1
        attempts == 5
      end

      sleeps = []
      expect(main).to receive(:sleep).exactly(4).times do |amt|
        sleeps << amt
      end

      messages = []
      expect(main).to receive(:puts).exactly(4).times do |msg|
        messages << msg
      end

      expect { task.execute }.not_to raise_error

      expected_sleeps = [5, 10, 20, 40]
      expect(attempts).to be(5)
      expect(sleeps).to eq(expected_sleeps)
      expect(messages).to eq(expected_sleeps.map { |amt| "Command #{npm_command} failed. Retrying in #{amt}s..." })
    end

    it "fails the command after too many tries" do
      allow(main).to receive(:sleep)

      expect(main).to receive(:system).with("cd #{Rails.root} && #{npm_command}").exactly(5).times.and_return(false)
      expect(main).to receive(:abort).with("\n== Command #{npm_command} failed ==") do |msg|
        raise SystemExit, msg
      end

      expect { task.execute }.to raise_error(SystemExit)
    end
  end
end
