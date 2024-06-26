/*
 * @flow strict
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import type {CowContext} from 'mutate-cow';
import * as React from 'react';

import {ARTIST_TYPE_PERSON} from '../../common/constants.js';
import GuessCase from '../../guess-case/MB/GuessCase/Main.js';

import FormRowText from './FormRowText.js';

type SortNamedEntityT = {
  +entityType: EditableEntityTypeT,
  +typeID?: number | null,
  ...
};

/* eslint-disable ft-flow/sort-keys */
export type ActionT =
  | {+type: 'guess-case-sortname', +entity: SortNamedEntityT}
  | {+type: 'set-sortname', +sortName: string}
  | {+type: 'copy-sortname'};
/* eslint-enable ft-flow/sort-keys */

export type StateT = {
  +nameField: FieldT<string | null>,
  +sortNameField: FieldT<string | null>,
};

export function runReducer(
  newState: CowContext<StateT>,
  action: ActionT,
) {
  switch (action.type) {
    case 'set-sortname': {
      newState.set('sortNameField', 'value', action.sortName);
      break;
    }
    case 'guess-case-sortname': {
      const {entityType, typeID} = action.entity;
      const isPerson =
        entityType === 'artist' && typeID === ARTIST_TYPE_PERSON;
      newState.set(
        'sortNameField', 'value',
        GuessCase.entities[entityType].sortname(
          newState.read().nameField.value ?? '',
          isPerson,
        ),
      );
      break;
    }
    case 'copy-sortname': {
      newState.set(
        'sortNameField', 'value',
        newState.read().nameField.value ?? '',
      );
      break;
    }
  }
}

component FormRowSortNameWithGuessCase(
  disabled: boolean = false,
  dispatch: (ActionT) => void,
  entity: SortNamedEntityT,
  field: FieldT<string | null>,
  label: React$Node = addColonText(l('Sort name')),
  required: boolean = false,
) {
  const handleSortNameChange = React.useCallback((
    event: SyntheticKeyboardEvent<HTMLInputElement>,
  ) => {
    dispatch({
      sortName: event.currentTarget.value,
      type: 'set-sortname',
    });
  }, [dispatch]);

  function handleGuessCase() {
    dispatch({entity, type: 'guess-case-sortname'});
  }

  function handleSortNameCopy() {
    dispatch({type: 'copy-sortname'});
  }

  return (
    <FormRowText
      className="with-guesscase"
      disabled={disabled}
      field={field}
      label={label}
      onChange={handleSortNameChange}
      required={required}
    >
      <button
        className="guesscase-sortname icon"
        disabled={disabled}
        onClick={handleGuessCase}
        title={l('Guess sort name')}
        type="button"
      />
      <button
        className="sortname-copy icon"
        disabled={disabled}
        onClick={handleSortNameCopy}
        title={l('Copy name')}
        type="button"
      />
    </FormRowText>
  );
}

export default FormRowSortNameWithGuessCase;
