require 'lru_redux'

module Sites

  class Viewer < Sinatra::Base

    NON_VIEWABLE_PATHS = [
      'cnames',
      'layout'
    ]

    def wiki_new
      Gollum::Wiki.new(ENV['SITES_BASE_PATH'] + "/" + env['wiki.name'] + '.git', {})
    end

    def initialize(app = nil)
      super(app)
      @cache = LruRedux::ThreadSafeCache.new(100)
    end

    def cache_key(wiki, key)
      rev = wiki.repo.head.commit.id
      "#{key}-#{rev}"
    end

    def get_layout(wiki)
      layout = wiki.file('layout.erb') || wiki.page('layout')
      if layout
        return layout.raw_data
      else
        return "<html><body><%= yield %></body></html>"
      end
    end

    def render_page(page_name, params)
      wiki = wiki_new

      key = cache_key(wiki, page_name)
      response.headers['X-Cache-Key'] = key

      @cache.getset(key) do
        if (@page = wiki.page(page_name))
          render :erb, @page.formatted_data, layout: get_layout(wiki)
        elsif (file = wiki.file(page_name))
          mimetype = MIME::Types.of page_name
          content_type mimetype[0]
          return file.raw_data
        else
          raise Sinatra::NotFound
        end
      end
    end

    helpers do
      def static_path(path)
        env['SCRIPT_PATH'] + path
      end
    end

    before do
      if env['viewer.auth']
        auth = Rack::Auth::Basic::Request.new(env)
        return if auth.provided? &&
          auth.basic? &&
          auth.credentials &&
          auth.credentials == [ENV['USERNAME'], ENV['PASSWORD']]

        headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
        halt 401, "Not authorized\n"
      end
    end

    NON_VIEWABLE_PATHS.each do |path|
      get "/#{path}" do
        raise Sinatra::NotFound
      end
    end

    get '/' do
      render_page('Home', params)
    end

    get '/*' do
      page_name = params[:splat][0].gsub(/\.html$/, '')
      render_page(page_name, params)
    end

  end

end
