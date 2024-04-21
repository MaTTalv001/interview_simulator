require 'rest-client'

class InterviewController < ApplicationController
  def index
    @repositories = fetch_repositories
  end

  def show
    repo_url = params[:repository]
    readme_contents = fetch_readme(repo_url)
    @questions = OpenAiService.generate_questions(readme_contents)
    session[:questions] = @questions  # 質問をセッションに保存
    session[:current_index] = 0       # 現在の質問インデックスを初期化
  
    redirect_to answer_question_path  # 質問回答用のビューへリダイレクト
  end

  # app/controllers/interview_controller.rb
  def process_answer
    # TODO回答をセッションに保存するロジック（後々のDB保存用）
    index = session[:current_index] + 1
    if index < session[:questions].length
      session[:current_index] = index
      redirect_to answer_question_path  # 次の質問へ
    else
      redirect_to interview_index_path  # 全ての質問が終了
    end
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
