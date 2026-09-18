# frozen_string_literal: true

require "prism"
require "parallel"
require "tempfile"

describe "Unused examples" do
  let(:ruby_files) do
    root = File.expand_path("..", __dir__)
    files = Dir.glob(File.join(root, "**", "{spec,test}", "**", "*.rb"))
    files.reject! { |f| f.include?("/vendor/") }
    files
  end

  it "codebase does not contain unused RSpec shared examples" do
    results = Parallel.map(ruby_files, in_processes: 2) do |file|
      collector = SharedExampleCollector.new
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

  it "registers usages passed as arguments" do
    temp_collector(
      <<~RUBY
        shared_examples "main" do
          it { is_expected.to be(true) }
        end

        shared_examples "subexample" do |scenario|
          it_behaves_like scenario
        end

        describe "foobar" do
          it_behaves_like "subexample", "main"
        end
      RUBY
    ) do |collector|
      unused = detect_unused([collector])
      expect(unused).to be_empty
    end
  end

  it "does not treat an unrelated extra argument as a usage" do
    temp_collector(
      <<~RUBY
        shared_examples "unrelated" do
          it { is_expected.to be(true) }
        end

        shared_examples "subexample" do |label|
          it { expect(label).to eq(label) }
        end

        describe "foobar" do
          it_behaves_like "subexample", "unrelated"
        end
      RUBY
    ) do |collector|
      unused = detect_unused([collector])
      expect(unused.map { |defn| defn[:name] }).to eq(["unrelated"])
    end
  end

  it "records dynamic usages inside a lambda-form shared example" do
    temp_collector(
      <<~RUBY
        shared_examples "main" do
          it { is_expected.to be(true) }
        end

        shared_examples "subexample", ->(scenario) { it_behaves_like scenario }

        describe "foobar" do
          it_behaves_like "subexample", "main"
        end
      RUBY
    ) do |collector|
      unused = detect_unused([collector])
      expect(unused).to be_empty
    end
  end

  it "keeps argument positions aligned when a non-string argument precedes a forwarded name" do
    temp_collector(
      <<~RUBY
        shared_examples "main" do
          it { is_expected.to be(true) }
        end

        shared_examples "subexample" do |ignored, scenario|
          it_behaves_like scenario
        end

        describe "foobar" do
          it_behaves_like "subexample", SOME_CONST, "main"
        end
      RUBY
    ) do |collector|
      unused = detect_unused([collector])
      expect(unused).to be_empty
    end
  end

  it "detects recursive lambda usage" do
    temp_collector(
      %(shared_examples "foobar", lambda { it_behaves_like "foobar" })
    ) do |collector|
      unused = detect_unused([collector])
      expect(unused).not_to be_empty
    end
  end

  it "detects recursive proc usage" do
    temp_collector(
      %(shared_examples "foobar", proc { it_behaves_like "foobar" })
    ) do |collector|
      unused = detect_unused([collector])
      expect(unused).not_to be_empty
    end
  end

  it "detects recursive proc arrow usage" do
    temp_collector(
      %(shared_examples "foobar", -> { it_behaves_like "foobar" })
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
    calls = results.flat_map(&:calls)
    dynamic_usages = results.flat_map(&:dynamic_usages)

    usages = results.flat_map(&:usages)
    usages = filter_recursive_usages(definitions, usages)
    usages += resolve_dynamic_usages(dynamic_usages, calls)

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
    by_name_and_file = definitions.group_by { |d| [d[:name], d[:file]] }

    usages.reject do |usage|
      candidates = by_name_and_file[[usage[:name], usage[:file]]]
      next false unless candidates

      candidates.any? { |d| d[:start_line] <= usage[:line] && usage[:line] <= d[:end_line] }
    end
  end

  # Resolves dynamic usages (e.g. `it_behaves_like scenario`, where `scenario`
  # is a block parameter of the enclosing shared example) against the extra
  # arguments passed at call sites that reference that shared example.
  #
  # @param dynamic_usages [Array<Hash>] Recorded dynamic usages, each tied to
  #   the definition whose parameter is being forwarded.
  # @param calls [Array<Hash>] All call sites, with their target name and any
  #   extra arguments passed (by position).
  # @return [Array<Hash>] Synthetic usages resolved from parameter forwarding.
  def resolve_dynamic_usages(dynamic_usages, calls)
    calls_by_target = calls.group_by { |call| call[:target] }

    dynamic_usages.flat_map do |dynamic_usage|
      defn = dynamic_usage[:defn]
      index = defn[:params].index(dynamic_usage[:param])
      next [] unless index

      candidates = calls_by_target[defn[:name]] || []
      candidates.filter_map do |call|
        next nil unless visible_from?(defn[:scope], call[:scope])

        name = call[:args][index]
        next nil unless name

        { name:, file: call[:file], line: call[:line], scope: call[:scope] }
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
    by_name = definitions.group_by { |d| d[:name] }

    usages.flat_map do |usage|
      candidates = by_name[usage[:name]]
      next [] unless candidates

      visible = candidates.select { |defn| visible_from?(defn[:scope], usage[:scope]) }
      next [] if visible.empty?

      depth = visible.map { |defn| defn[:scope].length }.max
      visible.select { |defn| defn[:scope].length == depth }
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

      collector = SharedExampleCollector.new
      collector.process_file(f.path)
      yield collector
    end
  end

  # A shared example collector that walks Prism's native AST directly
  # (no whitequark translation layer), detecting shared example definitions
  # and their usages and recording these with their scopes for further
  # inspection.
  class SharedExampleCollector < Prism::Visitor
    attr_reader :definitions, :usages, :calls, :dynamic_usages

    def initialize
      super
      @definitions = []
      @usages = []
      @calls = []
      @dynamic_usages = []
      @current_file = nil
      @scope_stack = []
      @definition_stack = []
    end

    # Processes a single file.
    #
    # @param file_path [String] Path to the file to process.
    # @return [void]
    def process_file(file_path)
      @current_file = file_path
      code = File.read(file_path)
      return unless relevant_file?(code)

      Prism.parse(code).value.accept(self)
    end

    # Visits every method call node. Prism unifies a call and its attached
    # block/do-end into a single CallNode (unlike the whitequark AST, which
    # wraps them as separate :send/:block nodes), so all definition, usage,
    # and scope handling is driven from here rather than split across
    # separate block/send visitors.
    #
    # @param node [Prism::CallNode] The call node.
    # @return [void]
    def visit_call_node(node)
      if shared_example_call?(node)
        handle_shared_example_definition(node)
        return
      end

      if example_group?(node)
        handle_example_group(node)
        return
      end

      record_usage(node) if usage_call?(node)
      visit_child_nodes(node)
    end

    private

    attr_reader :current_file, :scope_stack, :definition_stack

    # Handles a `shared_examples`/`shared_examples_for`/`shared_context` call,
    # in either form:
    #   shared_examples "foobar" do
    #     ...
    #   end
    #
    #   shared_examples "foobar", ->(scenario) { ... }
    #
    # @param node [Prism::CallNode] The node to inspect.
    # @return [void]
    def handle_shared_example_definition(node)
      body_node = node.block || lambda_argument(node)

      unless body_node
        visit_child_nodes(node)
        return
      end

      name = extract_shared_example_name(node)
      defn = record_shared_example(name, node, block_param_names(body_node))

      if defn
        definition_stack << defn
        visit_child_nodes(node)
        definition_stack.pop
      else
        visit_child_nodes(node)
      end
    end

    # Handles `describe`/`context` blocks, and `it_behaves_like` blocks (which
    # act as a customization block and also count as a usage of the shared
    # example being customized). The usage is recorded against the enclosing
    # scope, before the new scope is pushed, so it isn't misattributed to the
    # customization block's own scope.
    #
    # @param node [Prism::CallNode] The node to inspect.
    # @return [void]
    def handle_example_group(node)
      record_usage(node) if node.name == :it_behaves_like

      scope_stack << scope_for(node)
      visit_child_nodes(node)
      scope_stack.pop
    end

    # Detects if a node represents an example group within a spec (only when
    # a literal block is attached; `it_behaves_like "x"` without a block is a
    # plain usage, not a group).
    #
    # @param node [Prism::CallNode] The node to inspect.
    # @return [Boolean]
    def example_group?(node)
      return false unless node.block.is_a?(Prism::BlockNode)

      [:describe, :context, :it_behaves_like].include?(node.name)
    end

    # Defines a scope for the current node with its file path, call location
    # and call column.
    #
    # @param node [Prism::CallNode] The node to determine the scope for.
    # @return [Array<String, Integer, Integer>]
    def scope_for(node)
      location = node.location
      [current_file, location.start_line, location.start_column]
    end

    def current_scope
      scope_stack.dup
    end

    # Searches the file contents for relevant example groups or usages of
    # shared examples in order to skip irrelevant files from AST parsing for
    # performance.
    #
    # @param code [String] The code to inspect.
    # @return [Boolean]
    def relevant_file?(code)
      code.match?(/\b(?:shared_examples(?:_for)?|shared_context|it_behaves_like|include_examples|include_context)\b/)
    end

    # Records a shared example.
    #
    # @param name [String, nil] The name of the shared example.
    # @param node [Prism::CallNode] The node to record.
    # @param params [Array<Symbol>] The block/lambda parameter names, used to
    #   resolve dynamic usages such as `it_behaves_like scenario`.
    # @return [Hash, nil] The recorded definition, or nil if it had no static
    #   name.
    def record_shared_example(name, node, params)
      return nil if name.nil?

      location = node.location
      # A do-end block's own line span may or may not already be included in
      # the call node's location; take the wider of the two so recursive-usage
      # detection covers the full body either way.
      end_line = [location.end_line, node.block&.location&.end_line].compact.max

      defn = {
        name:,
        file: current_file,
        start_line: location.start_line,
        end_line:,
        scope: current_scope,
        params:
      }
      definitions << defn
      defn
    end

    # Records a usage of a shared example. Only the first argument is treated
    # as the shared-example identifier; any remaining string arguments are
    # recorded separately as call arguments (see #calls). If the identifier is
    # a local variable (e.g. `it_behaves_like scenario`), it's recorded as a
    # dynamic usage to be resolved against call arguments later.
    #
    # @param node [Prism::CallNode] The node to record.
    # @return [void]
    def record_usage(node)
      identifier = call_argument(node, 0)
      line = node.location.start_line

      extract_usage_names(node).each do |name|
        usages << { name:, file: current_file, line:, scope: current_scope }
        calls << {
          target: name,
          args: extract_call_arguments(node),
          file: current_file,
          line:,
          scope: current_scope
        }
      end

      record_dynamic_usage(identifier.name) if identifier.is_a?(Prism::LocalVariableReadNode)
    end

    # @param node [Prism::CallNode] The node to inspect.
    # @param index [Integer] Positional argument index.
    # @return [Prism::Node, nil]
    def call_argument(node, index)
      node.arguments&.arguments&.[](index)
    end

    # Extracts the shared-example identifier from a usage caller node, i.e.
    # only the first argument, when it's a static string.
    #
    # @param node [Prism::CallNode] The node to inspect.
    # @return [Array<String>]
    def extract_usage_names(node)
      identifier = call_argument(node, 0)
      return [] unless identifier.is_a?(Prism::StringNode)

      [identifier.unescaped]
    end

    # Extracts any extra arguments passed at a usage call site, beyond the
    # identifier itself, preserving their original positions. Non-string
    # arguments become nil placeholders rather than being dropped, so indices
    # stay aligned with the shared example's block parameter positions.
    #
    # @param node [Prism::CallNode] The node to inspect.
    # @return [Array<String, nil>]
    def extract_call_arguments(node)
      args = node.arguments&.arguments || []
      args.drop(1).map { |arg| arg.unescaped if arg.is_a?(Prism::StringNode) }
    end

    # Records a usage where the identifier is a local variable rather than a
    # static string, tying it to the nearest enclosing shared example whose
    # parameters include that variable name.
    #
    # @param param [Symbol] The local variable name used as the identifier.
    # @return [void]
    def record_dynamic_usage(param)
      defn = definition_stack.reverse_each.find { |candidate| candidate[:params]&.include?(param) }
      return unless defn

      dynamic_usages << { defn:, param: }
    end

    # Extracts the block/lambda parameter names, e.g. for
    # `shared_examples "x" do |scenario| ... end`, returns [:scenario].
    # Only required/optional/rest positional parameters are considered,
    # matching prior behavior (keyword parameters are not tracked).
    #
    # @param body_node [Prism::BlockNode, Prism::LambdaNode]
    # @return [Array<Symbol>]
    def block_param_names(body_node)
      block_params = body_node&.parameters
      return [] unless block_params.is_a?(Prism::BlockParametersNode)

      params = block_params.parameters
      return [] unless params

      names = params.requireds.map { |p| p.name if p.respond_to?(:name) }
      names += params.optionals.map { |p| p.name if p.respond_to?(:name) }
      names << params.rest.name if params.rest.respond_to?(:name)
      names.compact
    end

    # Detects if a node is a shared example call (definition form, regardless
    # of whether it has a block or lambda body attached).
    #
    # @param node [Prism::CallNode] The node to inspect.
    # @return [Boolean]
    def shared_example_call?(node)
      [:shared_examples, :shared_examples_for, :shared_context].include?(node.name)
    end

    # Extracts the shared example name from the shared example caller node.
    #
    # @param node [Prism::CallNode] The node to inspect.
    # @return [String, nil]
    def extract_shared_example_name(node)
      args = node.arguments&.arguments || []
      str_node = args.find { |arg| arg.is_a?(Prism::StringNode) }
      str_node&.unescaped
    end

    # Detects if a node is a shared example usage.
    #
    # @param node [Prism::CallNode] The node to inspect.
    # @return [Boolean]
    def usage_call?(node)
      [:include_examples, :include_context, :it_behaves_like].include?(node.name)
    end

    # Finds the lambda/proc argument in a shared example call, if present,
    # e.g.:
    #   shared_examples "test", -> { it_behaves_like "foobar" }
    #   shared_examples "test", lambda { it_behaves_like "foobar" }
    #   shared_examples "test", proc { it_behaves_like "foobar" }
    #
    # `->{}` parses as a Prism::LambdaNode, while `lambda{}`/`proc{}` parse as
    # ordinary CallNodes with a block attached — both are treated the same way
    # here, matching prior (whitequark-based) behavior.
    #
    # @param node [Prism::CallNode] The node to inspect.
    # @return [Prism::LambdaNode, Prism::BlockNode, nil]
    def lambda_argument(node)
      args = node.arguments&.arguments
      return nil unless args&.any?

      last = args.last
      return last if last.is_a?(Prism::LambdaNode)
      return last.block if last.is_a?(Prism::CallNode) && [:lambda, :proc].include?(last.name) && last.block

      nil
    end
  end
end
