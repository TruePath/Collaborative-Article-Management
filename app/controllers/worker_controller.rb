class WorkerController < ApplicationController
  def status
  	jid = params[:job_id]
  	@container = SidekiqStatus::Container.load(jid)
  	respond_to :json
  end
end
