# frozen_string_literal: true

# File: spec/support/tasks.rb
require "rake"

# Task names should be used in the top-level describe, with an optional
# "rake "-prefix for better documentation. Both of these will work:
#
# 1) describe "foo:bar" do ... end
#
# 2) describe "rake foo:bar" do ... end
#
# Favor including "rake "-prefix as in the 2nd example above as it produces
# doc output that makes it clear a rake task is under test and how it is
# invoked.
module TaskExampleGroup
  extend ActiveSupport::Concern

  included do
    # Make the Rake task available as `task` in your examples:
    subject(:task) { tasks[task_name] }

    let(:task_name) { self.class.top_level_description.sub(/\Arake /, "") }
    let(:tasks) { Rake::Task }
  end
end

# A collection of methods to help dealing with rake tasks output.
module RakeTaskOutputHelpers
  extend ActiveSupport::Concern

  included do
    let!(:original_stdout) { $stdout }

    before do
      $stdout = StringIO.new
    end

    after do
      $stdout = original_stdout
    end
  end

  def check_no_errors_have_been_printed
    expect($stdout.string).not_to include("ERROR:")
  end

  def check_some_errors_have_been_printed
    expect($stdout.string).to include("ERROR:")
  end

  def check_error_printed(type)
    expect($stdout.string).to include("ERROR: [#{type}]")
  end

  def check_message_printed(message)
    expect($stdout.string).to include(message)
  end
end

RSpec.configure do |config|
  # Tag Rake specs with `:task` metadata or put them in the spec/tasks dir
  config.define_derived_metadata(file_path: %r{/spec/tasks/}) do |metadata|
    metadata[:type] = :task
  end

  config.include TaskExampleGroup, type: :task
  config.include RakeTaskOutputHelpers, type: :task

  config.before(:suite) do
    Rails.application.load_tasks
  end
end
