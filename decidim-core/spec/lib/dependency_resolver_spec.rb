# frozen_string_literal: true

require "spec_helper"
require "bundler/lockfile_generator"

module Decidim
  describe DependencyResolver do
    subject { resolver }

    let(:resolver) { Decidim::DependencyResolver.instance }
    let(:root_path) { File.dirname(ENV.fetch("ENGINE_ROOT")) }

    # Make sure the resolver cache won't be messed up during these tests
    around do |example|
      original_cache = resolver.instance_variable_get(:@cache)
      resolver.instance_variable_set(:@cache, [])
      example.run
      resolver.instance_variable_set(:@cache, original_cache)
    end

    shared_examples "existing module" do
      describe "#module_path" do
        subject { resolver.module_path(gem) }

        let(:gem_path) { gem == "decidim" ? root_path : "#{root_path}/#{gem}" }

        it "returns the correct path" do
          expect(subject).to eq("#{gem_path}/lib/#{gem.gsub("-", "/")}.rb")
        end
      end

      describe "#available?" do
        subject { resolver.available?(gem) }

        it { is_expected.to be(true) }
      end

      describe "#loaded?" do
        subject { resolver.loaded?(gem) }

        it { is_expected.to be(true) }
      end

      describe "#needed?" do
        subject { resolver.needed?(gem) }

        it { is_expected.to be(true) }
      end
    end

    shared_examples "unexisting module" do
      describe "#lookup" do
        subject { resolver.lookup(gem) }

        it { is_expected.to be_nil }
      end

      describe "#module_path" do
        subject { resolver.module_path(gem) }

        it { is_expected.to be_nil }
      end

      describe "#available?" do
        subject { resolver.available?(gem) }

        it { is_expected.to be(false) }
      end

      describe "#loaded?" do
        subject { resolver.loaded?(gem) }

        it { is_expected.to be(false) }
      end

      describe "#needed?" do
        subject { resolver.needed?(gem) }

        it { is_expected.to be(false) }
      end
    end

    describe "#available?" do
      subject { resolver.available?("decidim-core") }

      context "when the gem is available but the file does not exist" do
        before do
          allow(File).to receive(:exist?).and_return(false)
        end

        it { is_expected.to be(false) }
      end
    end

    describe "#loaded?" do
      subject { resolver.loaded?("decidim-core") }

      context "when the gem is available but not loaded" do
        before do
          allow($LOADED_FEATURES).to receive(:include?).and_return(false)
        end

        it { is_expected.to be(false) }
      end
    end

    %w(
      decidim
      decidim-accountability
      decidim-admin
      decidim-api
      decidim-assemblies
      decidim-blogs
      decidim-budgets
      decidim-comments
      decidim-core
      decidim-debates
      decidim-forms
      decidim-generators
      decidim-meetings
      decidim-pages
      decidim-participatory_processes
      decidim-proposals
      decidim-sortitions
      decidim-surveys
      decidim-system
      decidim-templates
      decidim-verifications
      decidim-conferences
      decidim-consultations
      decidim-elections
      decidim-initiatives
      decidim-templates
    ).each do |decidim_gem|
      context "with #{decidim_gem}" do
        let(:gem) { decidim_gem }

        describe "#lookup" do
          subject { resolver.lookup(gem) }

          it "returns Bundler::LazySpecification" do
            expect(subject).to be_instance_of(Bundler::LazySpecification)
            expect(subject.name).to eq(gem)
          end
        end

        it_behaves_like "existing module"
      end
    end

    context "with an unexisting module" do
      let(:gem) { "decidim-foo" }

      it_behaves_like "unexisting module"
    end

    context "with a gem that is not a Decidim module" do
      let(:gem) { "rails" }

      it_behaves_like "unexisting module"

      context "when bundler is not available" do
        before do
          allow(resolver).to receive(:bundler?).and_return(false)
        end

        it_behaves_like "unexisting module"
      end
    end

    context "with a custom Gemfile" do
      let(:builder) do
        b = Bundler::Dsl.new
        b.eval_gemfile("TestGemfile", gemfile)
        b
      end
      let(:definition) do
        bd = nil
        builder.instance_eval do
          bd = Bundler::Definition.new("TestGemfile.lock", @dependencies, @sources, {})
        end
        bd
      end
      let(:gemfile) do
        <<~GEMFILE
          source "https://rubygems.org"

          #{gems.map { |gem| %(gem "#{gem}", path: "..") }.join("\n")}
        GEMFILE
      end
      let(:lockfile) do
        dummy_definition = builder.to_definition("Dummy.lock", {})
        Bundler::LockfileGenerator.generate(dummy_definition)
      end
      let(:gems) { %w(decidim-core decidim-budgets) }

      before do |example|
        # Silence the bundler output
        allow(Bundler.ui).to receive(:info)

        # Bundler specific to be able to pass it the TestGemfile.lock contents
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with("TestGemfile.lock").and_return(true)
        allow(Bundler).to receive(:read_file).and_call_original
        allow(Bundler).to receive(:read_file).with("TestGemfile.lock").and_return(lockfile)

        # Return the mocked definition instead of the actual one for the resolver
        definition.specs_for([:default]) # Materializes the spec
        allow(Bundler).to receive(:definition).and_return(definition)

        # CI DEBUG
        debug_lookup = Decidim::DependencyResolver::Lookup.new(debug: true)
        allow(Decidim::DependencyResolver::Lookup).to receive(:new).and_return(debug_lookup)
        puts "#{example.description} # #{example.metadata[:full_description]}"
        puts ">>>>> root"
        puts root_path
        puts "<<<<< root"
        puts ">>>>> dependencies"
        definition.dependencies.each { |dep| puts dep.name }
        puts "<<<<< dependencies"
        puts ">>>>> locked_gems"
        Bundler.definition.locked_gems.specs.find { |s| puts s.name if s.name =~ /^decidim/ }
        puts "<<<<< locked_gems"
      end

      context "with decidim-core" do
        let(:gem) { "decidim-core" }

        it_behaves_like "existing module"
      end

      context "with decidim-budgets" do
        let(:gem) { "decidim-budgets" }

        it_behaves_like "existing module"
      end

      # Dependency for decidim-core
      context "with decidim-api" do
        let(:gem) { "decidim-api" }

        it_behaves_like "existing module"
      end

      # Dependency for decidim-budgets
      context "with decidim-comments" do
        let(:gem) { "decidim-comments" }

        it_behaves_like "existing module"
      end

      # Not listed in the Gemfile and not a dependency
      context "with decidim-proposals" do
        let(:gem) { "decidim-proposals" }

        it_behaves_like "unexisting module"
      end
    end

    context "when bundler is not available" do
      let(:gem) { "decidim-core" }

      before do
        allow(resolver).to receive(:bundler?).and_return(false)
      end

      describe "#lookup" do
        subject { resolver.lookup(gem) }

        it "returns Gem::Specification" do
          expect(subject).to be_instance_of(Gem::Specification)
          expect(subject.name).to eq(gem)
        end
      end

      describe "#needed?" do
        subject { resolver.needed?(gem) }

        it { is_expected.to be(true) }

        context "when the gem is not loaded" do
          before do
            allow($LOADED_FEATURES).to receive(:include?).and_return(false)
          end

          it { is_expected.to be(false) }
        end
      end

      it_behaves_like "existing module"
    end
  end
end
