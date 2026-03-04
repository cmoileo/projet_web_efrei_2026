import { inject, Injectable } from '@angular/core';
import {
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  query,
  serverTimestamp,
  Timestamp,
  where,
  writeBatch,
  type DocumentSnapshot,
} from 'firebase/firestore';
import { FIREBASE_FIRESTORE } from '../../../core/tokens/firebase.tokens';
import { FIRESTORE_COLLECTIONS } from '../../../core/constants/firestore-collections';
import type {
  CalendarEvent,
  CreateEventPayload,
  UpdateEventPayload,
} from '../models/event.model';

@Injectable({ providedIn: 'root' })
export class EventService {
  private readonly firestore = inject(FIREBASE_FIRESTORE);

  async getEventsByVolunteer(volunteerId: string): Promise<CalendarEvent[]> {
    const q = query(
      collection(this.firestore, FIRESTORE_COLLECTIONS.EVENTS),
      where('volunteerId', '==', volunteerId),
    );
    const snap = await getDocs(q);
    return snap.docs
      .map(docToEvent)
      .sort((a, b) => a.date.getTime() - b.date.getTime());
  }

  async getEventById(eventId: string): Promise<CalendarEvent | null> {
    const ref = doc(this.firestore, FIRESTORE_COLLECTIONS.EVENTS, eventId);
    const snap = await getDoc(ref);
    if (!snap.exists()) return null;
    return docToEvent(snap);
  }

  async createEvent(payload: CreateEventPayload): Promise<void> {
    const batch = writeBatch(this.firestore);

    const eventRef = doc(collection(this.firestore, FIRESTORE_COLLECTIONS.EVENTS));
    batch.set(eventRef, {
      title: payload.title,
      description: payload.description,
      type: payload.type,
      date: Timestamp.fromDate(payload.date),
      volunteerId: payload.volunteerId,
      studentIds: payload.studentIds,
      linkedTaskId: payload.linkedTaskId ?? null,
      createdAt: serverTimestamp(),
    });

    if (payload.linkedTaskId) {
      const taskRef = doc(this.firestore, FIRESTORE_COLLECTIONS.TASKS, payload.linkedTaskId);
      batch.update(taskRef, {
        dueDate: Timestamp.fromDate(payload.date),
        updatedAt: serverTimestamp(),
      });
    }

    await batch.commit();
  }

  async updateEvent(eventId: string, data: UpdateEventPayload, previousLinkedTaskId?: string | null): Promise<void> {
    const batch = writeBatch(this.firestore);

    const eventRef = doc(this.firestore, FIRESTORE_COLLECTIONS.EVENTS, eventId);
    const updateData: Record<string, unknown> = {};
    if (data.title !== undefined) updateData['title'] = data.title;
    if (data.description !== undefined) updateData['description'] = data.description;
    if (data.type !== undefined) updateData['type'] = data.type;
    if (data.date !== undefined) updateData['date'] = Timestamp.fromDate(data.date);
    if (data.studentIds !== undefined) updateData['studentIds'] = data.studentIds;
    if (data.linkedTaskId !== undefined) updateData['linkedTaskId'] = data.linkedTaskId ?? null;

    batch.update(eventRef, updateData);

    const linkedTaskId = data.linkedTaskId !== undefined ? data.linkedTaskId : previousLinkedTaskId;
    if (linkedTaskId && data.date !== undefined) {
      const taskRef = doc(this.firestore, FIRESTORE_COLLECTIONS.TASKS, linkedTaskId);
      batch.update(taskRef, {
        dueDate: Timestamp.fromDate(data.date),
        updatedAt: serverTimestamp(),
      });
    }

    await batch.commit();
  }

  async deleteEvent(eventId: string): Promise<void> {
    const ref = doc(this.firestore, FIRESTORE_COLLECTIONS.EVENTS, eventId);
    await deleteDoc(ref);
  }
}

function docToEvent(snap: DocumentSnapshot): CalendarEvent {
  const data = snap.data()!;
  return {
    id: snap.id,
    title: data['title'] as string,
    description: data['description'] as string,
    type: data['type'] as CalendarEvent['type'],
    date: (data['date'] as Timestamp).toDate(),
    volunteerId: data['volunteerId'] as string,
    studentIds: (data['studentIds'] as string[]) ?? [],
    linkedTaskId: (data['linkedTaskId'] as string | null) ?? null,
    createdAt: (data['createdAt'] as Timestamp)?.toDate() ?? new Date(),
  };
}
