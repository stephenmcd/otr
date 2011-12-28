require "rubygems"
require "sinatra"
require "./lib/otr"

get "/:username" do
  call env.merge("PATH_INFO" => "/#{params[:username]}/#{params[:username]}")
end

get "/:gh_username/:bb_username" do
  cache_for = 60*60*24
  response["Cache-Control"] = "public, max-age=#{cache_for}"
  # response["Content-Type"] = params[:callback] ? "text/javascript" \
  #                                              : "application/json"
  output = OTR.get(params[:gh_username], params[:bb_username]).to_json
  output = "#{params[:callback]}(#{output});" if params[:callback]
  output
end