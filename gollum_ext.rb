require 'gollum/app'

class Precious::App
  def wiki_new
    Gollum::Wiki.new(ENV['SITES_BASE_PATH'] + env['SCRIPT_NAME'] + '.git', settings.wiki_options)
  end

  use Rack::Auth::Basic, "Protected Area" do |username, password|
    username == ENV['USERNAME'] && password == ENV['PASSWORD']
  end
end
