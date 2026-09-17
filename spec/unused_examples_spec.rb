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

  # Detects unused shared example definitions from the collector results.
  #
  # @param results [Array<SharedExampleCollector>] An array of collectors that
  #   have processed the source files.
  # @return [Array<Hash>] The actual unused shared example definitions.
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
  #
  # @param definitions [Array<Hash>] All shared example definitions.
  # @param usages [Array<Hash>] All shared example usages.
  # @return [Array<Hash>] The usages of shared examples that are not recursive
  #   usages as in the example.
  def filter_recursive_usages(definitions, usages)
    usages.reject do |usage|
      definitions.any? do |d|
        d[:name] == usage[:name] && d[:file] == usage[:file] &&
          d[:start_line] <= usage[:line] && usage[:line] <= d[:end_line]
      end
    end
  end

  # Formats the unused definitions for the spec failure message.
  #
  # @param unused [Array<Hash>] The unused definitions array.
  # @return [String] The formatted string of the unused definitions.
  def format_unused(unused)
    unused.map do |definition|
      "  #{definition[:name]} (#{definition[:file]}:#{definition[:start_line]})"
    end.join("\n")
  end

  # Checks whether a definition is visible from the scope where the usage is
  # defined in.
  #
  # @param definition_scope [Array<Array<String, Integer, Integer>>]
  #   The scope stack for the definition.
  # @param usage_scope [Array<Array<String, Integer, Integer>>]
  #   The scope stack for the usage.
  # @return [Boolean] A boolean indicating whether the definition is visible in
  #   the scope where the usage is defined.
  def visible_from?(definition_scope, usage_scope)
    definition_scope.length <= usage_scope.length &&
      definition_scope == usage_scope.first(definition_scope.length)
  end

  # Filters the shared example usages from all potential usages to those that
  # are visible in the scope where the usage is defined.
  #
  # @param definitions [Array<Hash>] All shared example definitions.
  # @param usages [Array<Hash>] All shared example usages.
  # @return [Array<Hash>] The usages of shared examples.
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

  # Creates a temp file with the provided contents, initializes a
  # SharedExampleCollector that is used to parse that file and yields the
  # collector instance.
  #
  # @param content [String] The contents of the temp file.
  # @yield [collector] The collector for the temp file that has processed the
  #   file.
  # @yieldparam [SharedExampleCollector] The collector instance.
  # @return [void]
  def temp_collector(content)
    Tempfile.create(["test", "_spec.rb"]) do |f|
      f.write(content)
      f.rewind

      collector = SharedExampleCollector.new(parser)
      collector.process_file(f.path)
      yield collector
    end
  end

  # A shared example collector that parses RSpec files, detects shared example
  # definitions and their usages and records these with their scopes for further
  # inspection.
  class SharedExampleCollector < Parser::AST::Processor
    attr_reader :definitions, :usages

    # Initializes the collector.
    #
    # @param parser [Class] The processor class to use.
    def initialize(parser)
      @parser = parser
      @definitions = []
      @usages = []
      @current_file = nil
      @scope_stack = []
    end

    # Processes a single file.
    #
    # @param file_path [String] Path to the file to process.
    # @return [AST::Node] (see AST::Processor::Mixin#process)
    def process_file(file_path)
      @current_file = file_path
      code = File.read(file_path)
      return unless relevant_file?(code)

      ast = parser.parse(code)
      process(ast)
    end

    # Parses blocks.
    #
    # @param node [Parser::AST::Node] The parsed node.
    # @return [AST::Node] (see AST::Node#updated)
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

    # Parses method calls.
    #
    # @param node [Parser::AST::Node] The parsed node.
    # @return [AST::Node] (see AST::Node#updated)
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

    # Detects if a node represents an example group within a spec.
    #
    # @param node [Parser::AST::Node] The node to inspect.
    # @return [Boolean] Boolean indicating whether an example group was
    #   detected.
    def example_group?(node)
      return false unless node&.type == :block

      send_node = node.children[0]
      return false unless send_node&.type == :send

      # `it_behaves_like` with a customization block creates a nested example
      # group, so definitions and usages inside it belong to a child scope.
      [:describe, :context, :it_behaves_like].include?(send_node.children[1])
    end

    # Defines a scope for the current node with its file path, call location and
    # call column.
    #
    # @param node [Parser::AST::Node] The node to determine the scope for.
    # @return [Array<String, Integer, Integer>] The scope array with the file
    #   path, call location and call column.
    def scope_for(node)
      location = node.location.expression
      [current_file, location.line, location.column]
    end

    # Returns the current scope stack, i.e. the call path up until the current
    # parsing state.
    #
    # @return [Array<Array<String, Integer, Integer>>] An array representing the
    #   current scope stack. Each item in the scope has the file name of the
    #   call path as well as the line an column number where this call happened.
    def current_scope
      scope_stack.dup
    end

    # Searches the file contents for relevant example groups or usages of shared
    # examples in order to skip irrelevant files from the AST parsing for
    # performance.
    #
    # @param code [String] The code to inspect.
    # @return [Boolean] Boolean indicating whether the file is relevant.
    def relevant_file?(code)
      code.match?(/\b(?:shared_examples(?:_for)?|shared_context|it_behaves_like|include_examples|include_context)\b/)
    end

    # Records a shared example.
    #
    # @param name [String] The name of the shared example.
    # @param node [Parser::AST::Node] The node to record.
    # @return [void]
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

    # Records a usage of a shared example.
    #
    # @param node [Parser::AST::Node] The node to record.
    # @return [void]
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

    # Extracts the shared example usage name from the shared example usage
    # caller node. For example, for
    #   it_behaves_like "foobar"
    #
    # This would return "foobar".
    #
    # @param node [Parser::AST::Node] The node to inspect.
    # @return [Array<String>] The names of the shared example usage.
    def extract_usage_names(node)
      node.children[2..].filter_map do |arg|
        arg.children[0] if arg.is_a?(Parser::AST::Node) && arg.type == :str
      end
    end

    # Detects if a node is a shared example definition.
    #
    # @param node [Parser::AST::Node] The node to inspect.
    # @return [Boolean] Boolean indicating whether a shared example was
    #   detected.
    def shared_example_definition?(node)
      return false unless node&.type == :block

      send_node = node.children[0]
      shared_example_call?(send_node)
    end

    # Detects if a node is a shared example call. Detects both cases, such as:
    #   shared_examples do "block example" do
    #     # ...
    #   end
    #
    #   shared_examples "callable example", -> { it_behaves_like "..." }
    #
    # @param node [Parser::AST::Node] The node to inspect.
    # @return [Boolean] Boolean indicating whether a shared example call was
    #   detected.
    def shared_example_call?(node)
      return false unless node&.type == :send

      method_name = node.children[1]
      [:shared_examples, :shared_examples_for, :shared_context].include?(method_name)
    end

    # Extracts the shared example name from the shared example caller node.
    # For example, for
    #   shared_examples "foobar" do
    #   end
    #
    # This would return "foobar".
    #
    # @param node [Parser::AST::Node] The node to inspect.
    # @return [String] The name of the shared example.
    def extract_shared_example_name(node)
      args = node.children[2..-1]
      str_node = args.find { |arg| arg&.type == :str }
      str_node&.children&.[](0)
    end

    # Detects if a node is a shared example usage.
    #
    # @param node [Parser::AST::Node] The node to inspect.
    # @return [Boolean] Boolean indicating whether a shared example usage was
    #   detected.
    def usage_call?(node)
      return false unless node&.type == :send

      method_name = node.children[1]
      [:include_examples, :include_context, :it_behaves_like].include?(method_name)
    end

    # Detects if a node is a customization block for a shared example, such as:
    #   it_behaves_like "foobar" do
    #     let(:customized_variable) { "test" }
    #   end
    #
    # @param node [Parser::AST::Node] The node to inspect.
    # @return [Boolean] Boolean indicating whether a customization block was
    #   detected.
    def customization_block?(node)
      return false unless node&.type == :send

      node.children[1] == :it_behaves_like
    end
  end
end
