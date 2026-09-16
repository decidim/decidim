# frozen_string_literal: true

# Not using parser/current because it can print out warnings.
require "parser/ruby#{RUBY_VERSION[0..2].delete(".")}"
require "parallel"

describe "Unused examples" do
  let(:parser) { Parser.const_get("Ruby#{RUBY_VERSION[0..2].delete(".")}") }
  let(:ruby_files) do
    root = File.expand_path("..", __dir__)
    Dir.glob(File.join(root, "**", "{spec,test}", "**", "*.rb"))
  end

  it "does not contain unused RSpec shared examples" do
    results = Parallel.map(ruby_files, in_processes: 2) do |file|
      collector = SharedExampleCollector.new(parser)
      collector.process_file(file)
      collector
    end

    definitions = results.flat_map(&:definitions)
    usages = results.flat_map(&:usages)

    # Filter out recursive usages (i.e. usage inside the example definition),
    # such as:
    #   shared_examples "foobar" do
    #     it_behaves_like "foobar"
    #   end
    usages = usages.reject do |usage|
      definition = definitions.find { |d| d[:name] == usage[:name] && d[:file] == usage[:file] }
      next false unless definition

      definition[:start_line] <= usage[:line] && usage[:line] <= definition[:end_line]
    end
    unused = definitions.reject do |defn|
      usages.any? { |usage| usage[:name] == defn[:name] }
    end

    expect(unused).to(
      be_empty,
      "Found unused RSpec shared examples:\n#{format_unused(unused)}"
    )
  end

  private

  def format_unused(unused)
    unused.map do |definition|
      "  #{definition[:name]} (#{definition[:file]}:#{definition[:start_line]})"
    end.join("\n")
  end

  class SharedExampleCollector < Parser::AST::Processor
    attr_reader :definitions, :usages

    def initialize(parser)
      @parser = parser
      @definitions = []
      @usages = []
      @current_file = nil
    end

    def process_file(file_path)
      @current_file = file_path
      code = File.read(file_path)
      return unless relevant_file?(code)

      ast = parser.parse(code)
      process(ast)
    end

    def on_block(node)
      if shared_example_definition?(node)
        name = extract_shared_example_name(node.children[0])
        record_shared_example(name, node)
      end

      super
    end

    def on_send(node)
      if shared_example_call?(node)
        # Cases such as:
        #   shared_examples "test", -> { it_behaves_like "foobar" }
        block_node = node.children[-1]
        if block_node.is_a?(Parser::AST::Node) && block_node.type == :block
          name = extract_shared_example_name(node)
          record_shared_example(name, node)
        end
      end

      record_usage(node) if usage_call?(node)

      super
    end

    private

    attr_reader :parser, :current_file

    def relevant_file?(code)
      code.match?(/\b(?:shared_examples(?:_for)?|shared_context|it_behaves_like|include_examples|include_context)\b/)
    end

    def record_shared_example(name, node)
      start_line = node.location.expression.line
      end_line = node.location.expression.last_line
      definitions << {
        name:,
        file: current_file,
        start_line:,
        end_line:
      }
    end

    def record_usage(node)
      names = extract_usage_names(node)
      line = node.location.expression.line
      names.each do |name|
        usages << {
          name:,
          file: current_file,
          line:
        }
      end
    end

    def shared_example_definition?(node)
      return false unless node&.type == :block

      send_node = node.children[0]
      shared_example_call?(send_node)
    end

    def shared_example_call?(node)
      return false unless node&.type == :send

      method_name = node.children[1]
      [:shared_examples, :shared_examples_for, :shared_context].include?(method_name)
    end

    def extract_shared_example_name(node)
      args = node.children[2..-1]
      str_node = args.find { |arg| arg&.type == :str }
      str_node&.children&.[](0)
    end

    def usage_call?(node)
      return false unless node&.type == :send

      method_name = node.children[1]
      [:include_examples, :include_context, :it_behaves_like].include?(method_name)
    end

    def extract_usage_names(node)
      args = node.children[2..-1]
      args.select { |arg| arg&.type == :str }.map { |str_node| str_node.children[0] }
    end
  end
end
