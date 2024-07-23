# frozen_string_literal: true

describe "Gemspec sanity" do
  let(:root_dir) { File.expand_path("..", __dir__) }
  let(:decidim_spec) { gemspec("decidim") }

  describe "decidim module specs" do
    let(:decidim_module_specs) do
      decidim_spec.dependencies.select { |dep| dep.name =~ /^decidim-/ }.map(&:to_spec)
    end

    it "do not require the `decidim` gem" do
      expect(decidim_module_specs).to all(be_decidim_clean)
    end
  end

  describe "decidim-dev spec" do
    let(:decidim_dev_spec) { gemspec("decidim-dev") }

    it "does not require the `decidim` gem" do
      expect(decidim_dev_spec).to be_decidim_clean
    end
  end

  def gemspec(name)
    gemspec_file =
      if name == "decidim"
        "#{root_dir}/decidim.gemspec"
      else
        "#{root_dir}/#{name}/#{name}.gemspec"
      end

    Gem::Specification.load(gemspec_file)
  end

  def be_decidim_clean
    BeDecidimClean.new
  end

  class BeDecidimClean
    attr_reader :spec

    def matches?(given_spec)
      @spec = given_spec
      spec.dependencies.all? { |dep| dep.name != "decidim" }
    end

    def failure_message
      "expected '#{spec.name}' gem not to have the 'decidim' gem as its dependency"
    end

    def failure_message_when_negated
      "expected '#{spec.name}' gem to have the 'decidim' gem as its dependency"
    end
  end
end
