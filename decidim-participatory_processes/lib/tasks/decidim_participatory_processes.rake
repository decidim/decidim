# frozen_string_literal: true

namespace :decidim_participatory_processes do
  desc "Change active step automatically in participatory processes"
  task :change_active_step, [] => :environment do
    Decidim::ParticipatoryProcesses::AutomateProcessesSteps.new.change_active_step
  end
end
