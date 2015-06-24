class WorkerController < ApplicationController
  def status
  	jid = params[:job_id]
  	@status = Resque::Plugins::Status::Hash.get(jid)
  	respond_to :json
  end
end
