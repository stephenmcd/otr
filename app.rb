require "rubygems"
require "sinatra"
require "dalli"
require "./lib/otr"

CACHE_TIMEOUT = 60*60*24
set :cache, Dalli::Client.new(ENV['MEMCACHE_SERVERS'] || "127.0.0.1",
                             :username => ENV['MEMCACHE_USERNAME'],
                             :password => ENV['MEMCACHE_PASSWORD'],
                             :expires_in => CACHE_TIMEOUT)

get "/:username" do
  call env.merge("PATH_INFO" => "/#{params[:username]}/#{params[:username]}")
end

get "/:gh_username/:bb_username" do
  response["Cache-Control"] = "public, max-age=#{CACHE_TIMEOUT}"
  response["Content-Type"] = params[:callback] ? "text/javascript" \
                                               : "application/json"
  cache_key = "#{params[:gh_username]}/#{params[:bb_username]}/"
  output = settings.cache.get cache_key
  if output.nil?
    output = OTR.get(params[:gh_username], params[:bb_username]).to_json
    settings.cache.set cache_key, output
  end
  output = "#{params[:callback]}(#{output});" if params[:callback]
  output
end