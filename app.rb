require 'gollum/app'

class Precious::App
  def wiki_new
    Gollum::Wiki.new(ENV['SITES_BASE_PATH'] + env['SCRIPT_NAME'] + '.git', settings.wiki_options)
  end

  use Rack::Auth::Basic, "Protected Area" do |username, password|
    username == ENV['USERNAME'] && password == ENV['PASSWORD']
  end
end

module Sites

  class Manager < Sinatra::Base

    use Rack::Auth::Basic, "Protected Area" do |username, password|
      username == ENV['USERNAME'] && password == ENV['PASSWORD']
    end
    
    get '/*' do
      @new_site_name = env['new_site_name']
      erb :create
    end

    post '/*' do
      @new_site_name = env['new_site_name']
      repo = Grit::Repo.init_bare(File.join(ENV['SITES_BASE_PATH'],  @new_site_name + ".git"))
      redirect "/#{@new_site_name}"
    end
  end

  class Middleware
    def initialize(app)
      @app = app
      @sites_manager = Sites::Manager.new
    end

    def call(env)
      path = env['PATH_INFO']
      root, site, path = path.split(/\//, 3)

      unless File.directory?(File.join(ENV['SITES_BASE_PATH'], site + ".git"))
        env['new_site_name'] = site
        return @sites_manager.call(env)
      end

      env['SCRIPT_NAME'] = "/#{site}"
      env['PATH_INFO'] = "/#{path}"

      @app.call(env)
    end
  end
end
