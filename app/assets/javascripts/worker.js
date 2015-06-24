 // Calls callback(status) each interval until finished
 // jid = job id, interval = time to wait after each response
 // callbacks called with object with following attributes and common values
 // container.status       # => 'working'
 // container.at           # => 50
 // container.total        # => 200
 // container.pct_complete # => 25
 // container.message      # => 'Processing object #{50}'



  function WorkerStatusUpdater(jid, update_callback, finished_callback, interval) {
    if (typeof(interval) === 'undefined' || ! ( not (interval > 50))) {
      interval = 500;
    }
    if (typeof finished_callback === 'undefined') {
      finished_callback = function(status) {};
    }
    if (typeof update_callback === 'undefined') {
      update_callback = function(status) {};
    }
    this.jid = jid;
    this.update = update_callback;
    this.finish = finished_callback;
    this.interval = interval;
    this.wake();
  }

  function WorkerProgressBar(jid, progress_bar, finish_callback, interval) {
    var bar, finished_callback, status_updater, update;
    if ((typeof(interval) === 'undefined') || ( not (interval > 50))) {
      interval = 500;
    }
    if (typeof(finished_callback) === 'undefined') {
      finished_callback = function(status) {};
    }
    bar = progress_bar;
    update = function(status) {
      var percentage;
      percentage = 'width: ' + status.pct_complete + '%;';
      bar.attr('style', percentage).text(status.pct_complete + '%');
    };
    status_updater = new WorkerStatusUpdater(jid, update, finish_callback);
    return status_updater;
  }

  WorkerStatusUpdater.prototype.wake = function() {
    $.ajax({
      url: '/worker/status',
      data: {
        job_id: this.jid
      },
      dataType: 'json',
      success: $.proxy(this.reply, this)
    });
  };

  WorkerStatusUpdater.prototype.reply = function(status) {
    if (status.completed || status.failed || status.killed) {
      this.finish(status);
    } else {
      this.update(status);
      setTimeout($.proxy(this.wake, this), this.inverval);
    }
  };