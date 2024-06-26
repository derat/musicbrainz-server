/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {QUALITY_NAMES} from '../../../static/scripts/common/constants.js';

import {SidebarProperty} from './SidebarProperties.js';

component SidebarDataQuality(quality: QualityT) {
  const name = QUALITY_NAMES.get(quality);
  let qualityClass;
  switch (quality) {
    case 2:
      qualityClass = 'high-data-quality';
      break;
    case 0:
      qualityClass = 'low-data-quality';
      break;
    default:
      qualityClass = '';
      break;
  }

  return name ? (
    <SidebarProperty
      className="data-quality"
      label={addColonText(l('Data quality'))}
    >
      <span className={qualityClass} />
      {name()}
    </SidebarProperty>
  ) : null;
}

export default SidebarDataQuality;
