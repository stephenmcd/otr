#!/usr/bin/env ruby

require "rubygems"
require "json"
require "rest_client"

module OTR
  VERSION = "0.1.2"

  def self.get_bb(username)
    repos = {}
    url = "https://api.bitbucket.org/1.0/users/#{username}/"
    JSON.parse(RestClient.get(url))["repositories"].map { |repo|
      Thread.new repo do |repo|
        name = repo["slug"]
        url = "https://bitbucket.org/#{username}/#{name}/descendants"
        html = RestClient.get(url).split("<span class=\"value\">")
        repos[name] = {
          "name" => name,
          "watchers" => html[4].to_i,
          "forks" => html[3].to_i,
          "fork" => repo["is_fork"],
          "urls" => ["https://bitbucket.org/#{username}/#{name}"]
        }
      end
    }.each { |thread| thread.join }
    repos
  end

  def self.get_gh(username)
    page = 0
    all_repos = []
    while true
      page += 1
      url = "https://api.github.com/users/#{username}/repos?page=#{page}"
      repos = JSON.parse(RestClient.get(url))
      break if repos.count == 0
      all_repos += repos
    end
    all_repos
  end

  def self.get(options)
    repos = self.get_bb(options[:bitbucket_username] || options[:username])
    self.get_gh(options[:github_username] || options[:username]).each do |repo|
      name = repo["name"]
      repos[name] ||= {"forks" => 0, "watchers" => 0, "urls" => []}
      repos[name]["urls"] << repo["url"]
      %w[watchers forks].each { |k| repos[name][k] += repo[k] }
      %w[fork name].each { |k| repos[name][k] ||= repo[k] }
    end
    repos.values
  end

end
