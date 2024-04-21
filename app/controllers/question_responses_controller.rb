class QuestionResponsesController < ApplicationController
    def edit
        @response = QuestionResponse.find(params[:id])
        # 権限チェックを追加して、他のユーザーの回答を編集できないようにする
        redirect_to review_questions_path, alert: "編集権限がありません" unless @response.user_id == session[:user_id]
    end
    
    def update
        @response = QuestionResponse.find(params[:id])
        if @response.user_id == session[:user_id] && @response.update(response_params)
            redirect_to review_questions_path, notice: "回答案を更新しました"
        else
            render :edit, alert: "回答案の更新に失敗しました"
        end
    end
    
    def destroy
        @response = QuestionResponse.find(params[:id])
        # レスポンスの所有者が現在のユーザーであるかを確認
        if @response.user_id == session[:user_id]
            @response.destroy!
            redirect_to review_questions_path, status: :see_other, notice: 'Response was successfully deleted.'
        else
            redirect_to review_questions_path, alert: 'You do not have permission to delete this response.'
        end
    end

    private
      
    def response_params
        params.require(:question_response).permit(:answer)
    end
end
