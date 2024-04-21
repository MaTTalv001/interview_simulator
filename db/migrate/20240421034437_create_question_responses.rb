class CreateQuestionResponses < ActiveRecord::Migration[7.1]
  def change
    create_table :question_responses do |t|
      t.references :user, null: false, foreign_key: true
      t.string :question, null: false
      t.string :answer
      t.string :category, null: false

      t.timestamps
    end
  end
end
