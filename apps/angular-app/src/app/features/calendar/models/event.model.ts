export type EventType = 'cours' | 'reunion' | 'deadline';

export type CalendarEvent = {
  id: string;
  title: string;
  description: string;
  type: EventType;
  date: Date;
  volunteerId: string;
  studentIds: string[];
  linkedTaskId: string | null;
  createdAt: Date;
};

export type CreateEventPayload = {
  title: string;
  description: string;
  type: EventType;
  date: Date;
  volunteerId: string;
  studentIds: string[];
  linkedTaskId: string | null;
};

export type UpdateEventPayload = {
  title?: string;
  description?: string;
  type?: EventType;
  date?: Date;
  studentIds?: string[];
  linkedTaskId?: string | null;
};

export const EVENT_TYPE_OPTIONS: { value: EventType; label: string }[] = [
  { value: 'cours', label: 'Cours' },
  { value: 'reunion', label: 'Réunion' },
  { value: 'deadline', label: 'Deadline' },
];

export const EVENT_TYPE_COLORS: Record<EventType, string> = {
  cours: '#4f6ef7',
  reunion: '#7c3aed',
  deadline: '#dc2626',
};
