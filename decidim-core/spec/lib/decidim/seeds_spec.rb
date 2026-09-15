# frozen_string_literal: true

require "spec_helper"
require "decidim/seeds"
require "rubocop"

module Decidim
  describe Seeds do
    describe "::SEEDS_CONFIG" do
      subject { described_class::SEEDS_CONFIG }

      let(:decidim_gems) { Gem.loaded_specs.keys.grep(/\Adecidim-/) }
      let(:decidim_gem_roots) { decidim_gems.index_with { |name| Gem.loaded_specs[name].full_gem_path } }
      let(:gem_seed_files) do
        decidim_gem_roots.to_h do |gem, path|
          paths =
            if gem == "decidim-comments"
              ["#{path}/app/models/decidim/comments/seed.rb"]
            else
              Dir.glob("#{path}/lib/**/seeds.rb")
            end

          [gem, paths]
        end
      end
      let(:processor_class) do
        Class.new(Parser::AST::Processor) do
          def on_send(node)
            return unless node.method_name == :config_value

            arg = node.first_argument
            return unless arg.sym_type?

            config_keys << arg.value unless config_keys.include?(arg.value)
          end

          def config_keys
            @config_keys ||= []
          end
        end
      end
      let(:utilized_configs) do
        gem_seed_files.to_h do |gem, paths|
          processor = processor_class.new
          paths.each do |path|
            source = RuboCop::ProcessedSource.from_file(path, RUBY_VERSION.to_f)
            source.ast.each_node do |node|
              processor.process(node)
            end
          end

          [gem, processor.config_keys]
        end
      end
      let(:unused_config_keys) { subject.keys - utilized_configs.values.flatten }

      it "defines both the slow and fast keys for all configs" do
        invalid = subject.reject do |_, values|
          values.keys == [:slow, :fast]
        end
        expect(invalid).to be_empty, "invalid seed configurations:\n#{invalid.keys.map { |k| ":#{k}" }.join(", ")}"
      end

      it "defines only keys that are used by seeds" do
        missing = utilized_configs.to_h do |gem, keys|
          [gem, keys - subject.keys]
        end
        missing.reject! { |_, keys| keys.empty? }

        expect(missing).to be_empty, "undefined seed configuration keys used:\n#{missing.map { |gem, keys| "#{gem}: #{keys.map { |k| ":#{k}" }.join(",")}" }.join("\n")}"

        expect(unused_config_keys).to be_empty, "unused seed configuration keys defined:\n#{unused_config_keys.map { |k| ":#{k}" }.join(", ")}"
      end
    end
  end
end
