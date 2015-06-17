# Calls callback(status) each interval until finished
# jid = job id, interval = time to wait after each response
# callbacks called with object with following attributes and common values
# container.status       # => 'working'
# container.at           # => 50
# container.total        # => 200
# container.pct_complete # => 25
# container.message      # => 'Processing object #{50}'

WorkerStatusUpdater = (jid, update_callback, finished_callback, interval) ->
  if typeof interval == 'undefined' or !(interval > 50)
    interval = 500
  if typeof finished_callback == 'undefined'

    finished_callback = (status) ->

  if typeof update_callback == 'undefined'

    update_callback = (status) ->

  @jid = jid
  @update = update_callback
  @finish = finished_callback
  @interval = interval
  return

WorkerProgressBar = (jid, progress_bar, finish_callback, interval) ->
  if typeof interval == 'undefined' or !(interval > 50)
    interval = 500
  if typeof finished_callback == 'undefined'

    finished_callback = (status) ->

  bar = progress_bar

  update = (status) ->
    percentage = 'width: ' + status['pct_complete'] + '%;'
    bar.attr('style', percentage).text status['pct_complete'] + '%'
    return

  status_updater = new WorkerStatusUpdater(jid, update, finish_callback)
  status_updater

WorkerStatusUpdater::wake = ->
  $.ajax
    url: '/worker/status'
    data: job_id: @jid
    dataType: 'json'
    success: @reply
  return

WorkerStatusUpdater::reply = (status) ->
  if status['status'] == 'working'
    @update status
    setTimeout $.proxy(@wake, this), @inverval
  else
    @finish status
  return
