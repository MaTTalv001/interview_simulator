# app/services/open_ai_service.rb
require 'openai'

class OpenAiService
  def self.generate_questions(readme_contents)
    client = OpenAI::Client.new(access_token: ENV['OPENAI_ACCESS_TOKEN']) 
    response = client.chat(
      parameters: {
        model: "gpt-3.5-turbo",
        messages: [
          {role: "system", content: "あなたはエンジニアの採用担当者で入社志望者との面談をします。志望者はポートフォリオのREADMEをあなたに提供します。その内容を確認し、エンジニア目線で、厳しい質問を5つ考えてください。なお、あなたの回答を配列化して扱うため、下記のフォーマットで回答してください。それ以外は不要です。フォーマット：　['質問1','質問2','質問3','質問4','質問5']"},
          {role: "user", content: readme_contents}
        ]
      }
    )

     # 文字列を配列に変換
     formatted_response = response["choices"][0]["message"]["content"].gsub("'", '"')
     JSON.parse(formatted_response)
  end
end
