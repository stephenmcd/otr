#!/usr/bin/env ruby

require "rubygems"
require "json"
require "rest_client"

module OTR

  def self.get_bb(username)
    repos = {}
    url = "https://api.bitbucket.org/1.0/users/#{username}/"
    JSON.parse(RestClient.get(url))["repositories"].map { |repo|
      Thread.new repo do |repo|
        name = repo["slug"]
        url = "https://bitbucket.org/#{username}/#{name}/descendants"
        html = RestClient.get(url)
        repos[name] = {
          "name" => name,
          "watchers" => html.split("followers-count\">")[1].to_i,
          "forks" => html.split("Forks/queues (")[1].to_i,
          "is_fork" => repo["is_fork"],
        }
      end
    }.each { |thread| thread.join }
    repos
  end

  def self.get_gh(username)
    url = "http://github.com/api/v1/json/#{username}"
    JSON.parse(RestClient.get(url))["user"]["repositories"]
  end

  def self.get(gh_username, bb_username)
    repos = self.get_bb(bb_username)
    self.get_gh(gh_username).each do |repo|
      name = repo["name"]
      repos[name] ||= {"forks" => 0, "watchers" => 0}
      repos[name]["watchers"] += repo["watchers"]
      repos[name]["forks"] += repo["forks"]
      repos[name]["is_fork"] ||= repo["fork"]
    end
    repos.values
  end

end
