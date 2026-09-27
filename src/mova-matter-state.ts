import type {
  MovaDevice,
  MovaVacuumStatus,
} from './mova-cloud.js';

export const MOVA_CLEANING_MODES = [
  {
    label: 'Saugen',
    mode: 0,
    modeTags: [
      { value: 16385 },
    ],
  },
  {
    label: 'Wischen',
    mode: 1,
    modeTags: [
      { value: 16386 },
    ],
  },
  {
    label: 'Saugen und Wischen',
    mode: 2,
    modeTags: [
      { value: 16385 },
      { value: 16386 },
    ],
  },
  {
    label: 'Tiefenreinigung',
    mode: 3,
    modeTags: [
      { value: 16384 },
      { value: 16385 },
      { value: 16386 },
    ],
  },
];

export const MATTER_AREA_TYPE: Readonly<Record<number, number>> = {
  1: 7,
  2: 4,
  3: 13,
  4: 10,
  5: 6,
  6: 3,
  8: 8,
  12: 13,
  15: 4,
};

export function mapMovaFaultToOperationalError(fault?: number): number {
  if (!fault) {
    return 0;
  }

  const table: Record<number, number> = {
    1: 65,
    2: 65,
    3: 65,
    8: 66,
    9: 69,
    10: 68,
    11: 67,
    12: 65,
    13: 65,
    15: 65,
    16: 65,
    17: 65,
    18: 65,
    19: 64,
    20: 1,
    29: 65,
    32: 70,
    33: 71,
    38: 67,
    39: 66,
    41: 69,
    1000: 64,
  };

  return table[fault] ?? 2;
}

export function getOperationalState(device: MovaDevice): number {
  switch (device.latestStatus) {
    case 1:
    case 7:
    case 12:
    case 23:
    case 25:
    case 37:
    case 38:
    case 96:
    case 97:
    case 101:
    case 103:
    case 104:
    case 105:
    case 107:
      return 1;

    case 3:
    case 4:
    case 21:
      return 2;

    case 5:
      return 64;

    case 6:
      return 65;

    case 13:
      return 66;

    case 22:
    case 34:
      return 67;

    case 9:
      return 68;

    case 20:
      return 69;

    case 21:
    case 107:
      return 70;

    default:
      return 0;
  }
}

export function getLiveOperationalState(
  status: MovaVacuumStatus,
): number {
  const pausedTaskStatuses = [
    6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18,
  ];

  const runningStates = [1, 7, 12];
  const runningStatuses = [2, 4, 5, 18, 19, 20, 22, 23, 24];

  if (status.fault && status.fault > 0) {
    return 3;
  }

  if (status.state === 4 || status.status === 12) {
    return 3;
  }

  if (
    status.state === 12
    || status.state === 21
    || status.status === 21
    || status.status === 107
  ) {
    return 70;
  }

  if (
    status.state === 11
    || status.state === 33
    || status.status === 121
    || status.dustCollectionStatus === 1
  ) {
    return 67;
  }

  if (status.status === 122) {
    return 69;
  }

  if (
    status.state === 9
    || status.selfWashBaseStatus === 1
    || status.status === 105
    || status.status === 114
  ) {
    return 68;
  }

  if (
    status.state === 5
    || status.state === 10
    || status.chargingStatus === 5
    || status.status === 3
    || status.selfWashBaseStatus === 3
  ) {
    return 64;
  }

  if (
    status.state === 3
    || status.status === 1
    || (
      status.taskStatus !== undefined
      && pausedTaskStatuses.includes(status.taskStatus)
    )
  ) {
    return 2;
  }

  if (
    (
      status.state !== undefined
      && runningStates.includes(status.state)
    )
    || (
      status.status !== undefined
      && runningStatuses.includes(status.status)
    )
  ) {
    return 1;
  }

  const batteryIsFullAtStation =
    status.battery !== undefined
    && status.battery >= 100
    && (
      status.state === 6
      || status.state === 8
      || status.state === 13
      || status.status === 6
      || status.status === 14
    )
    && (
      status.chargingStatus === 1
      || status.chargingStatus === 3
    );

  if (batteryIsFullAtStation) {
    return 0;
  }

  if (
    status.state === 6
    || status.chargingStatus === 1
    || status.status === 6
  ) {
    return 65;
  }

  if (
    status.state === 13
    || status.chargingStatus === 3
  ) {
    return 66;
  }

  return 0;
}

export function decodeMovaCleaningMode(
  rawValue: number | undefined,
): number | undefined {
  if (rawValue === undefined) {
    return undefined;
  }

  const wireMode = rawValue & 3;

  if (wireMode === 2) {
    return 0;
  }

  if (wireMode === 1) {
    return 1;
  }

  if (wireMode === 3) {
    return 3;
  }

  return 2;
}

export function getCleaningModeLabel(
  mode: number | undefined,
): string {
  if (mode === 0) {
    return 'Saugen';
  }

  if (mode === 1) {
    return 'Wischen';
  }

  if (mode === 2) {
    return 'Saugen und Wischen';
  }

  if (mode === 3) {
    return 'Tiefenreinigung';
  }

  return 'Unbekannt';
}

export function getBatteryLevel(device: MovaDevice): number {
  const battery = device.battery ?? 0;
  return Math.min(100, Math.max(0, battery));
}

export function clampBatteryLevel(battery: number): number {
  return Math.min(100, Math.max(0, battery));
}
