# frozen_string_literal: true

namespace :decidim_participatory_processes do
  desc "Change active step automatically in participatory processes"
  task :change_active_step, [] => :environment do
    Decidim::ParticipatoryProcesses::ChangeActiveStepJob.perform_later
  end
end
