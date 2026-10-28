class DiariesController < ApplicationController
  def index
    @user = User.find(params[:user_id])
    @diaries = @user.diaries.includes(
      diary_entries: {
        diary_attachments: { file_attachment: :blob }
      }
    )
  end
end
