class CommentsController < ApplicationController
  def create
    @article = Article.find(params[:article_id])

    @comment = @article.comments.new(comment_params)

    if @comment.save
      redirect_to article_path(@article), notice: 'Comment was successfully created.'
    else
      flash[:error] = "There was an error posting your comment: #{@comment.errors[:body].first}"
      redirect_to article_path(@article)
    end
  end

  def destroy
    @article = Article.find(params[:article_id])
    @comment = @article.comments.find(params[:id])
    @comment.destroy
    redirect_to article_path(@article), status: :see_other
  end

  private

  def comment_params
    params.require(:comment).permit(:commenter, :body, :status)
  end
end
