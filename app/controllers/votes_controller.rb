class VotesController < ApplicationController
  before_action :set_poll
  skip_before_action :verify_authenticity_token

  def new
    @vote = Vote.new
    @poll.questions.each{ |q| @vote.responses.build(question: q) }
    @referring_vote = Vote.find_by_hash(params[:vote_hash])

    if @referring_vote
      @vote.responses = @referring_vote.responses
    elsif params[:candidate_slug]
      @vote.responses.each do |response|
        @candidate = response.question.answers.select { |a| a.field_value.normalize == params[:candidate_slug].normalize }[0].try(:field_value)

        if @candidate
          response.frst_choice = @candidate
        else
          @vote.responses << @vote.responses.delete(response)
        end
      end
    end
  end

  def create
    @vote = Vote.new(vote_params)
    @vote.poll_id = @poll.id
    @vote.source = params[:source]
    @vote.referring_vote_id = Vote.find_by_hash(params[:vote_hash]).try(:id)
    @vote.candidate_slug = params[:candidate_slug]
    @vote.akid = params[:akid]
    @vote.auth_token = params[:authenticity_token]
    @vote.verified_auth_token = verified_request?
    @vote.ip_address = request.remote_ip
    @vote.session_cookie = session.id
    @vote.full_querystring = request.query_string

    respond_to do |format|
      if @vote.save
        # VoteMailer.with(vote: @vote).confirmation("#{request.protocol}#{request.host}", params[:poll]).deliver_later
        # AbstractJob.perform_later(@vote, :sync_to_actionkit)
        format.html { redirect_to params[:poll] ? "/#{params[:poll]}/v/#{@vote.hash}" : "/v/#{@vote.hash}" }
        format.json { render :show, status: :created, location: @vote }
      else
        format.html { render :new }
        format.json { render json: @vote.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @vote = Vote.find_by_hash! params[:vote_hash]
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def vote_params
      params.require(:vote).permit(:name, :zip, :email, :phone, :sms_opt_in, :source, :candidate_slug, :akid, responses_attributes: [:question_id, :frst_choice, :scnd_choice, :thrd_choice, :write_in])
    end
end
