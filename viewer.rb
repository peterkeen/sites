require 'lru_redux'

module Sites

  class Viewer < Sinatra::Base

    def wiki_new
      Gollum::Wiki.new(ENV['SITES_BASE_PATH'] + env['SCRIPT_NAME'] + '.git', {})
    end

    def initialize(app = nil)
      super(app)
      @cache = LruRedux::ThreadSafeCache.new(100)
    end

    def cache_key(wiki, key)
      rev = wiki.repo.head.commit.id
      "#{key}-#{rev}"
    end

    get '/' do
      wiki = wiki_new
      key = cache_key(wiki, 'Home')
      response.headers['X-Cache-Key'] = key

      @cache.getset(key) do
        @page = wiki.page('Home')
  
        layout = wiki.file('layout.erb')
        layout_data = if layout
          layout.raw_data
        else
          "<%= yield %>"
        end

        render :erb, @page.formatted_data, layout: layout_data
      end
    end

    get '/cnames' do
      raise Sinatra::NotFound
    end

    get '/*' do
      wiki = wiki_new
      page_name = params[:splat][0].gsub(/\.html$/, '')

      key = cache_key(wiki, page_name)
      response.headers['X-Cache-Key'] = key

      @cache.getset(key) do
        if (@page = wiki.page(page_name))
          layout = wiki.file('layout.erb')
          layout_data = if layout
            layout.raw_data
          else
            "<%= yield %>"
          end
    
          render :erb, @page.formatted_data, layout: layout_data
        elsif (file = wiki.file(page_name))
          mimetype = MIME::Types.of page_name
          content_type mimetype[0]
          return file.raw_data
        else
          raise Sinatra::NotFound
        end
      end
    end

  end

end
