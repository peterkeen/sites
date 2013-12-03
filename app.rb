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

  class Viewer < Sinatra::Base

    def wiki_new
      Gollum::Wiki.new(ENV['SITES_BASE_PATH'] + env['SCRIPT_NAME'] + '.git', {})
    end

    get '/' do
      wiki = wiki_new
      @page = wiki.page('Home')

      layout = wiki.file('layout.erb')
      layout_data = if layout
        layout.raw_data
      else
        "<%= yield %>"
      end

      render :erb, @page.formatted_data, layout: layout_data
    end

    get '/assets/*' do
      wiki = wiki_new
      file = wiki.file(File.join("assets", params[:splat][0]))
      if file
        mimetype = MIME::Types.of params[:splat][0]
        content_type mimetype[0]
        return file.raw_data
      else
        raise Sinatra::NotFound
      end
    end

    get '/cnames' do
      raise Sinatra::NotFound
    end

    get '/*' do
      wiki = wiki_new
      @page = wiki.page(params[:splat][0])

      layout = wiki.file('layout.erb')
      layout_data = if layout
        layout.raw_data
      else
        "<%= yield %>"
      end

      render :erb, @page.formatted_data, layout: layout_data
    end

  end

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
      @sites_viewer = Sites::Viewer.new
    end

    def call(env)

      host = env['SERVER_NAME']
      match = host.match(/(\w+)\.#{ENV['SITES_SERVER_NAME']}/)
      if match
        env['SCRIPT_NAME'] = "/#{match[1]}"
        return @sites_viewer.call(env)
      end

      path = env['PATH_INFO']
      root, site, path = path.split(/\//, 3)

      if site.nil? || site.empty?
        return [404, {}, "Not found"]
      end

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
