module Sites
  class Manager < Sinatra::Base

    use Rack::Auth::Basic, "Protected Area" do |username, password|
      username == ENV['USERNAME'] && password == ENV['PASSWORD']
    end
    
    get '/*' do
      @new_site_name = env['new_site_name']
      @all_sites = Dir.glob("#{ENV['SITES_BASE_PATH']}/*.git").select { |fn| File.directory?(fn) }.map{ |s| s.gsub(ENV['SITES_BASE_PATH'], '').gsub('.git', '') }
      erb :create
    end

    post '/*' do
      @new_site_name = env['new_site_name']
      repo = Grit::Repo.init_bare(File.join(ENV['SITES_BASE_PATH'],  @new_site_name + ".git"))
      redirect "/#{@new_site_name}"
    end
  end
end  
