require 'rest-client'

class InterviewController < ApplicationController
  def index
    @repositories = fetch_repositories
  end

  def show
    repo_url = params[:repository]
    @readme = fetch_readme(repo_url)
     Rails.logger.info("@readme:#{@readme}")
    render :show
  end
   

  private

  def fetch_readme(repo_url)
    # GitHub APIからREADMEを取得する
    uri = URI(repo_url)
    path_parts = uri.path.split('/')
    owner = path_parts[1]
    repo = path_parts[2]
    readme_url = "https://api.github.com/repos/#{owner}/#{repo}/readme"
  
    response = RestClient.get(readme_url, {
      Authorization: "token #{ENV['GITHUB_TOKEN']}",
      Accept: 'application/vnd.github.VERSION.raw'
    })
    response.body
  rescue RestClient::Exception => e
    Rails.logger.error "Failed to retrieve README: #{e.message}"
    "README is not available."
  end

  def fetch_repositories
    response = RestClient.get "https://api.github.com/user/repos", {
      Authorization: "token #{ENV['GITHUB_TOKEN']}",
      params: { visibility: 'public' }
    }
    JSON.parse(response.body).map { |repo| [repo['name'], repo['html_url']] }
  rescue RestClient::Exception => e
    Rails.logger.error "Failed to retrieve GitHub repositories: #{e.message}"
    []
  end
end
