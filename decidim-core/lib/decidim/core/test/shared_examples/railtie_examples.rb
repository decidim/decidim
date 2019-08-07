# frozen_string_literal: true

shared_examples_for "decidim module task loading" do |decidim_module|
  let(:railties) do
    Rails.application.railties
  end

  let(:railties_that_load_tasks) do
    railties.select { |r| r.railtie_name.match?(decidim_module) && !r.paths["lib/tasks"].to_a.empty? }
  end

  it "loads tasks just under one railtie" do
    expect(railties_that_load_tasks.size).to eq(1)
  end
end
