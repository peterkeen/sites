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

    get '/cnames' do
      raise Sinatra::NotFound
    end

    get '/*' do
      wiki = wiki_new

      if (@page = wiki.page(params[:splat][0]))
        layout = wiki.file('layout.erb')
        layout_data = if layout
          layout.raw_data
        else
          "<%= yield %>"
        end
  
        render :erb, @page.formatted_data, layout: layout_data
      elsif (file = wiki.file(params[:splat][0]))
        mimetype = MIME::Types.of params[:splat][0]
        content_type mimetype[0]
        return file.raw_data
      else
        raise Sinatra::NotFound
      end
    end

  end

end
