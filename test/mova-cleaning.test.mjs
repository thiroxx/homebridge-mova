import assert from 'node:assert/strict';
import test from 'node:test';

import {
  createStandardRoomCleaningSelections,
} from '../dist/mova-cleaning.js';

test('Standardmodus verwendet weiterhin einheitliche Werte', () => {
  assert.deepEqual(
    createStandardRoomCleaningSelections([3, 5, 3]),
    [
      [3, 1, 0, 0, 1],
      [5, 1, 0, 0, 2],
    ],
  );
});

test('übernimmt Saugstufe und Wassermenge aus der Cloud', () => {
  assert.deepEqual(
    createStandardRoomCleaningSelections([3], {
      suctionLevel: 2,
      waterVolume: 3,
      cleaningTimes: 2,
    }),
    [
      [3, 2, 2, 3, 1],
    ],
  );
});
