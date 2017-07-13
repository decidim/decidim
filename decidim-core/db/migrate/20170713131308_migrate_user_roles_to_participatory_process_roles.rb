class MigrateUserRolesToParticipatoryProcessRoles < ActiveRecord::Migration[5.1]
  def up
    participatory_processes = Decidim::ParticipatoryProcess.includes(:organization).all
    Decidim::User.find_each do |user|
      processes = participatory_processes.select {|process| process.organization == user.organization}
      return if user.roles.include? "admin"
      user.roles.each do |role|
        Decidim::ParticipatoryProcessUserRole.find_or_create_by(user: user, organization: organization, role: role)
      end
    end
    remove_column :decidim_users, :roles
  end
end
