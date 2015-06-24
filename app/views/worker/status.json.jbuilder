# json.methods @status.methods
json.status @status.status
json.message @status.message
json.queued @status.queued?
json.working @status.working?
json.completed @status.completed?
json.failed	@status.failed?
json.killed @status.killed?
json.num @status.num
json.total @status.total
json.pct_complete @status.pct_complete
json.time @status.time
