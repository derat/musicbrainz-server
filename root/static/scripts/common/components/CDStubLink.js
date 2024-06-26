/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import entityHref from '../utility/entityHref.js';

component CDStubLink(cdstub: CDStubT, content: string, subPath?: string) {
  return (
    <a href={entityHref(cdstub, subPath)}>
      <bdi>
        {content}
      </bdi>
    </a>
  );
}

export default CDStubLink;
