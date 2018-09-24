require 'lib/helpers'
helpers Helpers

### COMMON ###

config[:layout] = 'site'
activate :i18n, mount_at_root: :es

### DEVELOPMENT ###

configure :development do
  activate :livereload

  config[:debug_assets]          = true
  config[:livereload_css_target] = nil
end

### BUILD & DEPLOY ###

configure :build do
  activate :minify_css
  activate :minify_javascript
end

after_build do |builder|
  # We change the some files extension to make possible its interpretation as PHP code by the final server.
  %w(index deals).each do |page|
    builder.thor.run "mv #{__dir__}/build/#{page}.html #{__dir__}/build/#{page}.php"
  end
end

activate :autoprefixer do |prefix|
  prefix.browsers = 'last 2 versions'
end

activate :deploy do |deploy|
  deploy.deploy_method = :ftp
  deploy.host          = ENV['SERVER_HOST']
  deploy.path          = ENV['SERVER_PATH']
  deploy.user          = ENV['SERVER_USER']
  deploy.password      = ENV['SERVER_PASS']
  deploy.build_before  = true
end

activate :imageoptim do |options|
  options.manifest             = true # Use a build manifest to prevent re-compressing images between builds.
  options.skip_missing_workers = true # Silence problematic "image_optim" workers.
  options.verbose              = false # Causes "image_optim" to be in shouty-mode.
  options.nice                 = true # Setting "nice" and "threads" to true or nil will let options determine them.
  options.threads              = true
  options.image_extensions     = %w(.png .jpg .gif .svg) # Image extensions to attempt to compress.
  options.advpng               = { level: 4 }
  options.gifsicle             = { interlace: false }
  options.jpegoptim            = { strip: [ 'all' ], max_quality: 100 }
  options.jpegtran             = { copy_chunks: false, progressive: true, jpegrescan: true }
  options.optipng              = { level: 6, interlace: false }
  options.pngcrush             = { chunks: [ 'all' ], fix: false, brute: false }
  options.pngout               = { copy_chunks: false, strategy: 0 }
  options.svgo                 = {}
end

activate :asset_hash
activate :minify_html

### PAGES ###

# Navigation
config[:navigation] = [
  {
    key:  'home',
    text: 'navigation.home',
    link: '/'
  },
  {
    key:  'services',
    text: 'navigation.services.text',
    link: '#',
    items: [
      {
        key: 'laundry',
        text: 'navigation.services.items.laundry',
        link: '/laundry.html'
      },
      {
        key:  'dry_cleaning',
        text: 'navigation.services.items.dry_cleaning',
        link: '/dry-cleaning.html'
      },
      {
        key: 'leather_and_suede',
        text: 'navigation.services.items.leather_and_suede',
        link: '/leather-and-suede.html'
      },
      {
        key: 'wedding_and_event_clothing',
        text: 'navigation.services.items.wedding_and_event_clothing',
        link: '/wedding-and-event-clothing.html'
      },
      {
        key:  'uniforms',
        text: 'navigation.services.items.uniforms',
        link: '/uniforms.html'
      },
      {
        key:  'linen',
        text: 'navigation.services.items.linen',
        link: '/linen.html'
      }
    ]
  },
  {
    key:  'prices',
    text: 'navigation.prices',
    link: '/prices.html'
  },
  {
    key:  'faq',
    text: 'navigation.faq',
    link: '/faq.html'
  },
  {
    key:  'deals',
    text: 'navigation.deals',
    link: build? ? '/deals.php' : '/deals.html'
  },
  {
    key:  'contact',
    text: 'navigation.contact',
    link: '/contact.html'
  }
]

# Services
config[:navigation].select{ |x| x[:key] == 'services' }.first[:items].map{ |x| x[:key] }.each do |service|
  proxy "/#{service.gsub('_', '-')}.html", '/service.html', locals: { service: service }, ignore: true
end

# Contact
page 'send_email.php', layout: false
config[:contact_email] = 'lalavanderacb@gmail.com'
config[:errors_email]  = 'lalavanderacb@gmail.com'

# Google
config[:google_api_key]      = ENV['GOOGLE_API_KEY']
config[:gmaps_lat]           = '40.4298498'
config[:gmaps_lng]           = '-3.6422492'
config[:gmaps_zoom]          = '14'
config[:gplaces_place_id]    = 'ChIJJZgiAUIvQg0RNuOj8RudPRs'
config[:gplaces_min_rating]  = 4
config[:gplaces_max_reviews] = 25

# Facebook
config[:facebook_token]      = ENV['FACEBOOK_TOKEN']
config[:facebook_page_id]    = 1845404685734378
config[:facebook_max_posts]  = 15
