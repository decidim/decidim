# frozen_string_literal: true

require "spec_helper"

describe "Bullet initializer" do # rubocop:disable RSpec/DescribeClass
  subject(:run_initializer) { load_initializer_template }

  let(:template_path) do
    File.expand_path("../../../decidim-generators/lib/decidim/generators/app_templates/bullet_initializer.rb", __dir__)
  end
  let(:flag_names) do
    %w(DECIDIM_BULLET_N_PLUS_ONE DECIDIM_BULLET_UNUSED_EAGER DECIDIM_BULLET_COUNTER_CACHE)
  end

  def load_initializer_template
    registered = []
    allow(Rails.application.config).to receive(:after_initialize) { |&block| registered << block }
    load template_path
    registered.each(&:call)
    registered
  end

  around do |example|
    original_env = flag_names.index_with { |name| ENV.fetch(name, nil) }
    flag_names.each { |name| ENV.delete(name) }

    original = {
      enable: Bullet.enable?,
      n_plus_one: Bullet.instance_variable_get(:@n_plus_one_query_enable),
      unused_eager: Bullet.instance_variable_get(:@unused_eager_loading_enable),
      counter_cache: Bullet.instance_variable_get(:@counter_cache_enable),
      stacktrace_includes: Bullet.stacktrace_includes.dup,
      notifier_raise: UniformNotifier::Raise.instance_variable_get(:@exception_class)
    }

    begin
      example.run
    ensure
      original_env.each { |name, value| value.nil? ? ENV.delete(name) : ENV[name] = value }
      Bullet.enable = original[:enable]
      Bullet.n_plus_one_query_enable = original[:n_plus_one]
      Bullet.unused_eager_loading_enable = original[:unused_eager]
      Bullet.counter_cache_enable = original[:counter_cache]
      Bullet.stacktrace_includes.replace(original[:stacktrace_includes])
      UniformNotifier::Raise.instance_variable_set(:@exception_class, original[:notifier_raise])
    end
  end

  it "registers an after_initialize hook" do
    expect(run_initializer.size).to eq(1)
  end

  context "when boost_performance is enabled" do
    before do
      allow(Rails.application.config).to receive(:boost_performance).and_return(true)
    end

    it "does not register the after_initialize hook" do
      expect(run_initializer).to be_empty
    end
  end

  describe "default settings" do
    before { run_initializer }

    it "enables Bullet only in local environments" do
      expect(Bullet.enable?).to eq(Rails.env.local?)
    end

    it "raises errors on unoptimized queries" do
      expect(UniformNotifier::Raise.active?).to eq(Bullet::Notification::UnoptimizedQueryError)
    end

    it "detects N+1 queries" do
      expect(Bullet.n_plus_one_query_enable?).to be(true)
    end

    it "does not detect unused eager loading by default" do
      expect(Bullet.unused_eager_loading_enable?).to be(false)
    end

    it "detects counter cache opportunities" do
      expect(Bullet.counter_cache_enable?).to be(true)
    end

    it "filters the stacktrace on decidim frames" do
      expect(Bullet.stacktrace_includes).to eq(%w(decidim-))
    end
  end

  describe "environment flags" do
    context "when DECIDIM_BULLET_N_PLUS_ONE is disabled" do
      before do
        ENV["DECIDIM_BULLET_N_PLUS_ONE"] = "false"
        run_initializer
      end

      it "does not detect N+1 queries" do
        expect(Bullet.n_plus_one_query_enable?).to be(false)
      end
    end

    context "when DECIDIM_BULLET_UNUSED_EAGER is enabled" do
      before do
        ENV["DECIDIM_BULLET_UNUSED_EAGER"] = "true"
        run_initializer
      end

      it "detects unused eager loading" do
        expect(Bullet.unused_eager_loading_enable?).to be(true)
      end
    end

    context "when DECIDIM_BULLET_COUNTER_CACHE is disabled" do
      before do
        ENV["DECIDIM_BULLET_COUNTER_CACHE"] = "0"
        run_initializer
      end

      it "does not detect counter cache opportunities" do
        expect(Bullet.counter_cache_enable?).to be(false)
      end
    end
  end
end
