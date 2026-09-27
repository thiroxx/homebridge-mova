import assert from 'node:assert/strict';
import test from 'node:test';

import {
  decodeMovaCleaningMode,
  mapMovaFaultToOperationalError,
  MOVA_CLEANING_MODES,
} from '../dist/mova-matter-state.js';

test('veröffentlicht Saugen, Wischen, Kombi und Tiefenreinigung', () => {
  assert.deepEqual(
    MOVA_CLEANING_MODES.map(({ mode, label }) => ({ mode, label })),
    [
      { mode: 0, label: 'Saugen' },
      { mode: 1, label: 'Wischen' },
      { mode: 2, label: 'Saugen und Wischen' },
      { mode: 3, label: 'Tiefenreinigung' },
    ],
  );
});

test('kennzeichnet Reinigungsmodi mit Matter-Tags', () => {
  assert.deepEqual(
    MOVA_CLEANING_MODES.map(({ modeTags }) => modeTags),
    [
      [{ value: 16385 }],
      [{ value: 16386 }],
      [{ value: 16385 }, { value: 16386 }],
      [{ value: 16384 }, { value: 16385 }, { value: 16386 }],
    ],
  );
});

test('normalisiert MOVA-Wire-Modi auf Matter-Clean-Modes', () => {
  assert.equal(decodeMovaCleaningMode(5122), 0);
  assert.equal(decodeMovaCleaningMode(5121), 1);
  assert.equal(decodeMovaCleaningMode(5120), 2);
  assert.equal(decodeMovaCleaningMode(5123), 3);
  assert.equal(decodeMovaCleaningMode(undefined), undefined);
});

test('mappt MOVA-Fehler auf Matter Operational Errors', () => {
  assert.equal(mapMovaFaultToOperationalError(0), 0);
  assert.equal(mapMovaFaultToOperationalError(8), 66);
  assert.equal(mapMovaFaultToOperationalError(11), 67);
  assert.equal(mapMovaFaultToOperationalError(19), 64);
  assert.equal(mapMovaFaultToOperationalError(33), 71);
});
