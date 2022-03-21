# frozen_string_literal: true

namespace :decidim_participatory_processes do
  desc "Change active step automatically in participatory processes"
  task :change_active_step, [] => :environment do
    Decidim::ParticipatoryProcesses::AutomateProcessesSteps.new.change_active_step
  end

  task :enqueue_change_active_step do
    require "active_support"
    require "active_job"
    require_relative "../../app/jobs/decidim/participatory_processes/change_active_step_job"
    Decidim::ParticipatoryProcesses::ChangeActiveStepJob.perform_later
  end
end
