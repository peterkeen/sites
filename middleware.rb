module Sites
  class Middleware
    def initialize(app)
      @app = app
      @sites_manager = Sites::Manager.new
      @sites_viewer = Sites::Viewer.new
    end

    def call(env)

      host = env['SERVER_NAME']
      path = env['PATH_INFO']

      match = nil
      cnames = cname_map
      cnames.each do |site, names|
        names.each_with_index do |name, i|
          if name == host
            if i != 0
              return [301, {'Location' => "http://#{names[0]}#{path}"}, []]
            else
              match = [nil, name]
              break
            end
          end
          break if match
        end
      end

      if match
        env['SCRIPT_NAME'] = "/#{match[1]}"
        return @sites_viewer.call(env)
      end

      if host != ENV['SITES_SERVER_NAME']
        return [404, {}, 'not found']
      end

      root, site, path = path.split(/\//, 3)

      unless File.directory?(File.join(ENV['SITES_BASE_PATH'], site + ".git"))
        env['new_site_name'] = site
        return @sites_manager.call(env)
      end

      env['SCRIPT_NAME'] = "/#{site}"
      env['PATH_INFO'] = "/#{path}"

      @app.call(env)
    end

    def cname_map
      cnames = {}
      @all_sites = Dir.glob("#{ENV['SITES_BASE_PATH']}/*.git").select { |fn| File.directory?(fn) }
      @all_sites.each do |site|
        site_name = site.gsub(ENV['SITES_BASE_PATH'], '').gsub('.git', '').gsub('/', '')
        wiki = Gollum::Wiki.new(site, {})
        names = wiki.page('cnames')
        next unless names
        cnames[site_name] = names.raw_data.split("\n")
      end
      cnames
    end
  end
end
