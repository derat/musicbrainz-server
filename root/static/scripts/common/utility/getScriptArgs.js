/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {captureException} from '@sentry/browser';

function getCurrentScript() {
  let currentScript = document.currentScript;

  // IE11. Likely doesn't work with async or defer.
  if (!currentScript) {
    const scripts = document.getElementsByTagName('script');
    currentScript = scripts[scripts.length - 1];
  }

  return currentScript;
}

function getScriptArgs(): mixed {
  const currentScript = getCurrentScript();
  if (currentScript) {
    const args = currentScript.getAttribute('data-args');
    if (nonEmpty(args)) {
      try {
        return JSON.parse(args);
      } catch (error) {
        console.error(error);
        captureException(error);
      }
    }
  }
  return {};
}

export default getScriptArgs;
