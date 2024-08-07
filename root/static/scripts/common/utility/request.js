/*
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';

var nextAvailableTime = new Date().getTime();
var previousDeferred = null;
var timeout = 1000;

function makeRequest(ajaxConfig, context, deferred) {
  deferred.jqXHR = $.ajax({dataType: 'json', ...ajaxConfig})
    .done(function (...args) {
      if (!deferred.aborted) {
        deferred.resolveWith(context, args);
      }
    })
    .fail(function (...args) {
      if (!deferred.aborted) {
        deferred.rejectWith(context, args);
      }
    });

  deferred.jqXHR.sentData = ajaxConfig.data;
}

function request(ajaxConfig, context) {
  var deferred = $.Deferred();
  var now = new Date().getTime();
  var later;

  if (nextAvailableTime - now <= 0) {
    makeRequest(ajaxConfig, context, deferred);

    // nextAvailableTime is in the past.
    nextAvailableTime = now + timeout;
  } else {
    later = function () {
      if (!deferred.aborted && !deferred.complete) {
        makeRequest(ajaxConfig, context, deferred);
      } else if (deferred.next) {
        deferred.next();
      }
      deferred.complete = true;
    };

    if (previousDeferred) {
      previousDeferred.next = later;
    }
    previousDeferred = deferred;

    setTimeout(later, nextAvailableTime - now);

    // nextAvailableTime is in the future.
    nextAvailableTime += timeout;
  }

  var promise = deferred.promise();

  promise.abort = function () {
    if (deferred.jqXHR) {
      deferred.jqXHR.abort();
    } else {
      deferred.aborted = true;
    }
  };

  return promise;
}

export default request;
