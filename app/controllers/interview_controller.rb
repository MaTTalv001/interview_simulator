require 'rest-client'

class InterviewController < ApplicationController
  def index
    if session[:user_id].present?
      current_user = User.find(session[:user_id])
      @repositories = fetch_repositories(current_user.nickname)
    else
      redirect_to login_path, alert: "You must be logged in to access this page."
    end
  end

  def show
    repo_url = params[:repository]
    readme_contents = fetch_readme(repo_url)
    @questions = OpenAiService.generate_questions(readme_contents)
    session[:questions] = @questions  # 質問をセッションに保存
    session[:current_index] = 0       # 現在の質問インデックスを初期化
  
    redirect_to answer_question_path  # 質問回答用のビューへリダイレクト
  end

  def process_answer
    answer = params[:answer]
    question = session[:questions][session[:current_index]]
    current_user = User.find(session[:user_id])  # 仮にセッションにユーザーIDがあると仮定

    current_user.question_responses.create(
      question: question,
      answer: answer,
      category: "README質問"
    )

    index = session[:current_index] + 1
    if index < session[:questions].length
      session[:current_index] = index
      redirect_to answer_question_path
    else
      session.delete(:questions)
      session.delete(:current_index)
      redirect_to interview_index_path, notice: '全ての質問に回答しました。'
    end
  end


  def start_generic
    current_user = User.find(session[:user_id])
    @questions = Question.order("RAND()").limit(5)
    session[:questions] = @questions.map(&:content)
    session[:current_index] = 0

    redirect_to answer_generic_question_path  # 汎用質問回答用のビューへリダイレクト
  end

  def process_generic_answer
    answer = params[:answer]
    question_content = session[:questions][session[:current_index]]
    current_user = User.find(session[:user_id])

    current_user.question_responses.create(
      question: question_content,
      answer: answer,
      category: "一般質問"
    )

    index = session[:current_index] + 1
    if index < session[:questions].length
      session[:current_index] = index
      redirect_to answer_generic_question_path
    else
      session.delete(:questions)
      session.delete(:current_index)
      redirect_to interview_index_path, notice: '全ての質問に回答しました。'
    end
  end

  def review
    current_user = User.find(session[:user_id])
    @responses = current_user.question_responses.order(created_at: :desc)
  end
   

  private

  def fetch_readme(repo_url)
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

  def fetch_repositories(nickname)
    response = RestClient.get "https://api.github.com/users/#{nickname}/repos", {
      Authorization: "token #{ENV['GITHUB_TOKEN']}",
      params: { visibility: 'all' }
    }
    JSON.parse(response.body).map { |repo| [repo['name'], repo['html_url']] }
  rescue RestClient::Exception => e
    Rails.logger.error "Failed to retrieve GitHub repositories: #{e.message}"
    []
  end
end
