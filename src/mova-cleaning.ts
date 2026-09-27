export type MovaRoomCleaningSelection = readonly [
  roomId: number,
  cleaningTimes: number,
  suctionLevel: number,
  waterVolume: number,
  order: number,
];

export interface MovaRoomCleaningOptions {
  cleaningTimes?: number;
  suctionLevel?: number;
  waterVolume?: number;
}

export function createStandardRoomCleaningSelections(
  roomIds: readonly number[],
  options: MovaRoomCleaningOptions = {},
): MovaRoomCleaningSelection[] {
  const uniqueRoomIds = [...new Set(roomIds)]
    .filter(roomId => Number.isInteger(roomId) && roomId > 0);

  if (uniqueRoomIds.length === 0) {
    throw new Error(
      'Für die Raumreinigung wurde kein gültiger Raum ausgewählt.',
    );
  }

  const cleaningTimes = options.cleaningTimes ?? 1;
  const suctionLevel = options.suctionLevel ?? 0;
  const waterVolume = options.waterVolume ?? 0;

  return uniqueRoomIds.map(
    (roomId, index) => [
      roomId,
      cleaningTimes,
      suctionLevel,
      waterVolume,
      index + 1,
    ],
  );
}
