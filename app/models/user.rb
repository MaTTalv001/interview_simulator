class User < ApplicationRecord
    has_many :question_responses, dependent: :destroy
end
