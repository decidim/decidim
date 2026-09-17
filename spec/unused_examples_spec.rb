# frozen_string_literal: true

# Not using parser/current because it can print out warnings.
require "parser/ruby#{RUBY_VERSION[0..2].delete(".")}"
require "parallel"
require "tempfile"

describe "Unused examples" do
  let(:parser) { Parser.const_get("Ruby#{RUBY_VERSION[0..2].delete(".")}") }
  let(:ruby_files) do
    root = File.expand_path("..", __dir__)
    files = Dir.glob(File.join(root, "**", "{spec,test}", "**", "*.rb"))
    files.reject! { |f| f.include?("/vendor/") }
    files
  end

  it "codebase does not contain unused RSpec shared examples" do
    results = Parallel.map(ruby_files, in_processes: 2) do |file|
      collector = SharedExampleCollector.new(parser)
      collector.process_file(file)
      collector
    end

    unused = detect_unused(results)

    expect(unused).to(
      be_empty,
      "Found unused RSpec shared examples:\n#{format_unused(unused)}"
    )
  end

  it "does not record recursive usages" do
    temp_collector(
      <<~RUBY
        describe "test" do
          shared_examples "foobar" do
            it { is_expected.to be(true) }

            it_behaves_like "foobar"
          end
        end
      RUBY
    ) do |collector|
      unused = detect_unused([collector])
      expect(unused).not_to be_empty
    end
  end

  it "records usages with the same recursive name in another scope" do
    temp_collector(
      <<~RUBY
        describe "another" do
          shared_examples "foobar" do
            it { is_expected.to be(true) }
          end

          it_behaves_like "foobar"
        end

        describe "test" do
          shared_examples "foobar" do
            it { is_expected.to be(true) }

            it_behaves_like "foobar"
          end
        end
      RUBY
    ) do |collector|
      unused = detect_unused([collector])
      expect(unused).not_to be_empty
      expect(unused.count).to be(1)
    end
  end

  it "does not record out-of-scope shared examples as used" do
    temp_collector(
      <<~RUBY
        describe "outer" do
          shared_examples "foobar" do
            it { is_expected.to be(true) }
          end
        end

        describe "sibling" do
          it_behaves_like "foobar"
        end
      RUBY
    ) do |collector|
      unused = detect_unused([collector])
      expect(unused).not_to be_empty
    end
  end

  it "does not record it_behaves_like as a usage when the shared example is under it" do
    temp_collector(
      <<~RUBY
        describe "test" do
          it_behaves_like "customizable" do
            shared_examples "customizable" do
              it { is_expected.to be(true) }
            end
          end
        end
      RUBY
    ) do |collector|
      unused = detect_unused([collector])
      expect(unused).not_to be_empty
    end
  end

  private

  def detect_unused(results)
    definitions = results.flat_map(&:definitions)
    usages = results.flat_map(&:usages)
    usages = filter_recursive_usages(definitions, usages)

    used = Set.new(resolve_usages(definitions, usages).map(&:object_id))
    definitions.reject { |defn| used.include?(defn.object_id) }
  end

  # Filter out recursive usages (i.e. usage inside the example definition), such
  # as:
  #   shared_examples "foobar" do
  #     it_behaves_like "foobar"
  #   end
  def filter_recursive_usages(definitions, usages)
    usages.reject do |usage|
      definitions.any? do |d|
        d[:name] == usage[:name] && d[:file] == usage[:file] &&
          d[:start_line] <= usage[:line] && usage[:line] <= d[:end_line]
      end
    end
  end

  def format_unused(unused)
    unused.map do |definition|
      "  #{definition[:name]} (#{definition[:file]}:#{definition[:start_line]})"
    end.join("\n")
  end

  def visible_from?(definition_scope, usage_scope)
    definition_scope.length <= usage_scope.length &&
      definition_scope == usage_scope.first(definition_scope.length)
  end

  def resolve_usages(definitions, usages)
    usages.flat_map do |usage|
      candidates = definitions.select do |defn|
        defn[:name] == usage[:name] && visible_from?(defn[:scope], usage[:scope])
      end
      next [] if candidates.empty?

      depth = candidates.map { |defn| defn[:scope].length }.max
      candidates.select { |defn| defn[:scope].length == depth }
    end
  end

  def temp_collector(content)
    Tempfile.create(["test", "_spec.rb"]) do |f|
      f.write(content)
      f.rewind

      collector = SharedExampleCollector.new(parser)
      collector.process_file(f.path)
      yield collector
    end
  end

  class SharedExampleCollector < Parser::AST::Processor
    attr_reader :definitions, :usages

    def initialize(parser)
      @parser = parser
      @definitions = []
      @usages = []
      @current_file = nil
      @scope_stack = []
    end

    def process_file(file_path)
      @current_file = file_path
      code = File.read(file_path)
      return unless relevant_file?(code)

      ast = parser.parse(code)
      process(ast)
    end

    def on_block(node)
      if example_group?(node)
        send_node = node.children[0]

        if customization_block?(send_node)
          # `it_behaves_like "x" do ... end` both uses "x" in the enclosing
          # scope and opens a nested scope for whatever the block defines or
          # uses. Record the usage before pushing, so it isn't misattributed to
          # the customization block's own scope.
          record_usage(send_node)

          scope_stack << scope_for(node)
          process(node.children[1]) # block args
          process(node.children[2]) # block body
        else
          scope_stack << scope_for(node)
          super
        end
        scope_stack.pop
      else
        if shared_example_definition?(node)
          name = extract_shared_example_name(node.children[0])
          record_shared_example(name, node)
        end

        super
      end
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

    attr_reader :parser, :current_file, :scope_stack

    def example_group?(node)
      return false unless node&.type == :block

      send_node = node.children[0]
      return false unless send_node&.type == :send

      # `it_behaves_like` with a customization block creates a nested example
      # group, so definitions and usages inside it belong to a child scope.
      [:describe, :context, :it_behaves_like].include?(send_node.children[1])
    end

    def scope_for(node)
      location = node.location.expression
      [current_file, location.line, location.column]
    end

    def current_scope
      scope_stack.dup
    end

    def relevant_file?(code)
      code.match?(/\b(?:shared_examples(?:_for)?|shared_context|it_behaves_like|include_examples|include_context)\b/)
    end

    def record_shared_example(name, node)
      return if name.nil?

      start_line = node.location.expression.line
      end_line = node.location.expression.last_line
      definitions << {
        name:,
        file: current_file,
        start_line:,
        end_line:,
        scope: current_scope
      }
    end

    def record_usage(node)
      line = node.location.expression.line
      extract_usage_names(node).each do |name|
        usages << {
          name:,
          file: current_file,
          line:,
          scope: current_scope
        }
      end
    end

    def extract_usage_names(node)
      node.children[2..].filter_map do |arg|
        arg.children[0] if arg.is_a?(Parser::AST::Node) && arg.type == :str
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

    def customization_block?(node)
      return false unless node&.type == :send

      node.children[1] == :it_behaves_like
    end
  end
end
