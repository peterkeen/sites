require 'lru_redux'
require 'yui/compressor'
require 'image_optim'

module Sites

  class Viewer < Sinatra::Base

    NON_VIEWABLE_PATHS = [
      'cnames',
      'layout'
    ]

    COMPRESSORS = {
      'application/javascript' => lambda { |data| YUI::JavaScriptCompressor.new(munge: true).compress(data) },
      'text/css' => lambda { |data| YUI::CssCompressor.new.compress(data) },
      'image/png' => lambda { |data| ImageOptim.new(pngout: false, advpng: {level: 0}, optipng: {level: 3}).optimize_image_data(data) rescue data },
      'image/jpeg' => lambda { |data| ImageOptim.new.optimize_image_data(data) rescue data }
    }

    set :compress_assets, ENV['RACK_ENV'] == 'production'

    def wiki_new
      Gollum::Wiki.new(ENV['SITES_BASE_PATH'] + "/" + env['wiki.name'] + '.git', {})
    end

    def initialize(app = nil)
      super(app)
      @cache = LruRedux::ThreadSafeCache.new(1000)
    end

    def cache_key(wiki, key)
      rev = wiki.repo.head.commit.id
      "#{key}-#{rev}-#{env['SCRIPT_NAME']}"
    end

    def get_layout(wiki)
      layout = wiki.file('layout.erb') || wiki.page('layout')
      if layout
        return layout.raw_data
      else
        return "<html><body><%= yield %></body></html>"
      end
    end

    def compress_data(data, mime_type)
      p mime_type
      p COMPRESSORS.has_key?(mime_type.to_s)
      if settings.compress_assets && COMPRESSORS.has_key?(mime_type.to_s)
        return COMPRESSORS[mime_type.to_s].call(data)
      else
        return data
      end
    end

    def render_page(page_name, params)
      wiki = wiki_new

      key = cache_key(wiki, page_name)
      response.headers['X-Cache-Key'] = key

      mimetype = MIME::Types.of page_name
      content_type mimetype[0] if mimetype

      @cache.getset(key) do
        if (@page = wiki.page(page_name))
          render :erb, @page.formatted_data, layout: get_layout(wiki)
        elsif (file = wiki.file(page_name) || wiki.file(page_name + '.erb'))
          raw_data = file.raw_data
          if file.name.end_with? '.erb'
            raw_data = render :erb, raw_data, layout: false
          end

          compress_data(raw_data, mimetype[0])
        else
          raise Sinatra::NotFound
        end
      end
    end

    helpers do
      def static_path(path)
        env['SCRIPT_NAME'] + path
      end

      def page_title
        @page.metadata[:title] || @page.title
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
