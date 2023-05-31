# frozen_string_literal: true

module AxeMatchers
  def self.axe_version
    @axe_version ||= begin
      package = JSON.load_file(Rails.root.join("node_modules/axe-core/package.json"))
      package["version"]
    end
  end

  def self.axe_mainline_version
    @axe_mainline_version ||= axe_version.split(".")[0..1].join(".")
  end

  class ResultFormatter
    def initialize(result)
      @result = result
      @violations = result["violations"]
    end

    def format
      <<~MESSAGE

        Found #{violations.count} accessibility #{violations.count == 1 ? "violation" : "violations"}:

        #{violation_messages.join("\n")}
      MESSAGE
    end

    def violation_messages
      violations.each_with_index.map do |violation, index|
        nodes = violation["nodes"]
        [
          "#{index + 1}) #{violation["id"]}: #{violation["help"]} (#{violation["impact"]})",
          indent_lines(violation["helpUrl"], 1),
          indent_lines("The following #{nodes.length} #{nodes.length == 1 ? "node" : "nodes"} violate this rule:", 1),
          "",
          indent_lines(node_messages_for(nodes), 2),
          ""
        ]
      end.flatten
    end

    private

    attr_reader :result, :violations

    def indent_lines(lines, indent_level = 1)
      indent = "    " * indent_level
      Array(lines).flatten.map { |line| line.length.positive? ? "#{indent}#{line}" : "" }.join("\n")
    end

    def node_messages_for(nodes)
      nodes.map do |node|
        [
          "Selector: #{Array(node["target"]).join(", ")}",
          ("HTML: #{node["html"].gsub(/^\s*|\n*/, "")}" unless node["html"].nil?),
          fix(node["all"], "Fix all of the following:"),
          fix(node["none"], "Fix all of the following:"),
          fix(node["any"], "Fix any of the following:")
        ].compact.presence.tap { |messages| messages&.push("") }
      end.compact
    end

    def fix(checks, message)
      valid_checks = checks.compact
      [
        (message unless valid_checks.empty?),
        *valid_checks.map { |check| "- #{check["message"]}" }
      ].compact
    end
  end

  class BeAxeClean
    def matches?(page)
      @results = execute_axe(page)
      results["violations"].count.zero?
    end

    def failure_message
      ResultFormatter.new(results).format
    end

    def failure_message_when_negated
      "Expected to find accessibility violations. None were detected."
    end

    private

    attr_reader :results

    def execute_axe(page)
      load_axe(page)

      script = <<-JS
        var callback = arguments[arguments.length - 1];
        var context = document;
        var options = {};
        axe.run(context, options).then(res => JSON.parse(JSON.stringify(res))).then(callback);
      JS
      page = page.driver if page.respond_to?("driver")
      page = page.browser if page.respond_to?("browser") && !page.browser.is_a?(::Symbol)
      page.execute_async_script(script)
    end

    def load_axe(page)
      jslib = Rails.root.join("node_modules/axe-core/axe.min.js")
      page.execute_script jslib.read
    end
  end

  def be_axe_clean
    BeAxeClean.new
  end
end

RSpec.configure do |config|
  config.include AxeMatchers
end

shared_examples_for "accessible page" do
  it "passes accessibility tests" do
    expect(page).to be_axe_clean
  end

  it "passes HTML validation" do
    # Capybara is stripping the doctype out of the HTML which is required for
    # the validation. If it does not exist, add it there.
    html = page.source
    html = "<!DOCTYPE html>\n#{html}" unless html.strip.match?(/^<!DOCTYPE/i)

    expect(html).to be_valid_html
  end
end
