require "rubygems"
require "sinatra"
require "dalli"
require "rdoc"
require "./lib/otr"

CACHE_TIMEOUT = 60*60*24
set :cache, Dalli::Client.new(ENV['MEMCACHE_SERVERS'] || "127.0.0.1",
                             :username => ENV['MEMCACHE_USERNAME'],
                             :password => ENV['MEMCACHE_PASSWORD'],
                             :expires_in => CACHE_TIMEOUT)

get "/" do
  rdoc open("#{Dir.pwd}/README.rdoc").read, :layout_engine => :erb
end

get "/:username" do
  call env.merge("PATH_INFO" => "/#{params[:username]}/#{params[:username]}")
end

get "/:github_username/:bitbucket_username" do
  response["Cache-Control"] = "public, max-age=#{CACHE_TIMEOUT}"
  response["Content-Type"] = params[:callback] ? "text/javascript" \
                                               : "application/json"
  options = {
    :github_username => params[:github_username],
    :bitbucket_username => params[:bitbucket_username],
  }
  cache_key = options.values.join("/")
  output = settings.cache.get cache_key
  if output.nil?
    output = OTR.get(options).to_json
    settings.cache.set cache_key, output
  end
  output = "#{params[:callback]}(#{output});" if params[:callback]
  output
end