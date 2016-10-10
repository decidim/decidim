if !Rails.env.production? || ENV["SEED"]
  puts "Creating Decidim::Core seeds..."

  staging_organization = Decidim::Organization.create!(
    name: "Decidim Staging",
    host: ENV["DECIDIM_HOST"] || "localhost"
  )

  Decidim::User.create!(
    email: "admin@decidim.org",
    password: "decidim123456",
    password_confirmation: "decidim123456",
    organization: staging_organization,
    confirmed_at: Time.current,
    roles: ["admin"]
  )

  Decidim::User.create!(
    email: "user@decidim.org",
    password: "decidim123456",
    password_confirmation: "decidim123456",
    confirmed_at: Time.current,
    organization: staging_organization
  )

  Decidim::ParticipatoryProcess.create!(
    title: 'Urbanistic plan for Newtown neighbourhood',
    slug: 'urbanistic-plan-for-newtown-neighbourhood',
    subtitle: 'Go for it!',
    hashtag: '#urbaNewtown',
    short_description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed feugiat ex at neque vehicula, non facilisis mi laoreet. Duis id felis at libero cursus tincidunt vehicula posuere elit. Cras venenatis ultricies ligula, a eleifend sem viverra at. Cras quis venenatis diam. Etiam consectetur, nulla nec consequat sollicitudin, risus ipsum rutrum lacus, a ultrices risus mauris in metus. Aenean dignissim ullamcorper efficitur. Sed eget elit suscipit, efficitur dui vitae, placerat quam. Pellentesque sodales congue tortor ut maximus. Cras a nulla enim. Aliquam ac lacinia lorem, nec vehicula turpis.',
    description: '<p>Mauris nec diam nibh. Quisque tincidunt aliquam malesuada. Aliquam eget velit pretium, placerat metus in, auctor dui. In mollis, ligula vel interdum hendrerit, eros sem bibendum justo, ac ornare orci nulla non mauris. Phasellus tincidunt urna est, sit amet condimentum est efficitur fringilla. Sed egestas tellus nec ligula vehicula, nec suscipit tellus consequat. Mauris interdum eu urna mollis volutpat. Maecenas condimentum pharetra lectus, quis egestas sem finibus et. Ut non est et metus ultrices convallis ut vel magna. Donec sagittis justo nec varius vestibulum.</p>

    <p>Phasellus eget urna at nisl pellentesque tempus in at sem. Sed consectetur, lectus sit amet aliquam aliquet, augue justo iaculis eros, sodales mollis mauris odio vel elit. Nam ut tristique ipsum, in consectetur elit. Nullam tellus dui, placerat ut lobortis laoreet, cursus vestibulum nunc. Praesent consequat nisi non iaculis laoreet. Nullam sed molestie arcu. Vivamus ultricies dapibus neque tristique maximus. Cras quis pulvinar leo. Cras semper enim non justo lacinia cursus in eu enim. Pellentesque id erat pellentesque, semper nisi non, dignissim odio. In hac habitasse platea dictumst. Sed hendrerit purus elit, in condimentum ligula iaculis nec. Cras semper metus non lectus placerat, a auctor mauris feugiat. Sed euismod tempus egestas. Fusce porttitor vel enim non tincidunt. Duis non risus eu justo ultricies dignissim.</p>',
    organization: staging_organization
  )
end
