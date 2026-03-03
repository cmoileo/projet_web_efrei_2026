import { inject, Injectable } from '@angular/core';
import {
  addDoc,
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  query,
  serverTimestamp,
  Timestamp,
  updateDoc,
  where,
  type DocumentSnapshot,
} from 'firebase/firestore';
import { FIREBASE_FIRESTORE } from '../../../core/tokens/firebase.tokens';
import { FIRESTORE_COLLECTIONS } from '../../../core/constants/firestore-collections';
import type { CreateTaskPayload, Task, TaskFirestoreStatus, UpdateTaskPayload } from '../models/task.model';

@Injectable({ providedIn: 'root' })
export class TaskService {
  private readonly firestore = inject(FIREBASE_FIRESTORE);

  async getTasksByVolunteer(uid: string): Promise<Task[]> {
    const q = query(
      collection(this.firestore, FIRESTORE_COLLECTIONS.TASKS),
      where('createdBy', '==', uid),
    );
    const snap = await getDocs(q);
    return snap.docs
      .map(docToTask)
      .sort((a, b) => a.dueDate.getTime() - b.dueDate.getTime());
  }

  async getTasksByStudent(uid: string): Promise<Task[]> {
    const q = query(
      collection(this.firestore, FIRESTORE_COLLECTIONS.TASKS),
      where('assignedTo', '==', uid),
    );
    const snap = await getDocs(q);
    return snap.docs
      .map(docToTask)
      .sort((a, b) => a.dueDate.getTime() - b.dueDate.getTime());
  }

  async getTaskById(id: string): Promise<Task | null> {
    const ref = doc(this.firestore, FIRESTORE_COLLECTIONS.TASKS, id);
    const snap = await getDoc(ref);
    if (!snap.exists()) return null;
    return docToTask(snap);
  }

  async createTask(payload: CreateTaskPayload): Promise<void> {
    await addDoc(collection(this.firestore, FIRESTORE_COLLECTIONS.TASKS), {
      title: payload.title,
      description: payload.description,
      dueDate: Timestamp.fromDate(payload.dueDate),
      status: 'todo',
      assignedTo: payload.assignedTo,
      createdBy: payload.createdBy,
      createdAt: serverTimestamp(),
      updatedAt: serverTimestamp(),
    });
  }

  async updateTask(taskId: string, data: UpdateTaskPayload): Promise<void> {
    const ref = doc(this.firestore, FIRESTORE_COLLECTIONS.TASKS, taskId);
    const updateData: Record<string, unknown> = { updatedAt: serverTimestamp() };
    if (data.title !== undefined) updateData['title'] = data.title;
    if (data.description !== undefined) updateData['description'] = data.description;
    if (data.dueDate !== undefined) updateData['dueDate'] = Timestamp.fromDate(data.dueDate);
    if (data.status !== undefined) updateData['status'] = data.status;
    if (data.assignedTo !== undefined) updateData['assignedTo'] = data.assignedTo;
    await updateDoc(ref, updateData);
  }

  async updateTaskStatus(taskId: string, status: TaskFirestoreStatus): Promise<void> {
    const ref = doc(this.firestore, FIRESTORE_COLLECTIONS.TASKS, taskId);
    await updateDoc(ref, { status, updatedAt: serverTimestamp() });
  }

  async deleteTask(taskId: string): Promise<void> {
    const ref = doc(this.firestore, FIRESTORE_COLLECTIONS.TASKS, taskId);
    await deleteDoc(ref);
  }
}

function docToTask(snap: DocumentSnapshot): Task {
  const data = snap.data()!;
  return {
    id: snap.id,
    title: data['title'] as string,
    description: data['description'] as string,
    dueDate: (data['dueDate'] as Timestamp).toDate(),
    status: data['status'] as TaskFirestoreStatus,
    assignedTo: data['assignedTo'] as string,
    createdBy: data['createdBy'] as string,
    createdAt: (data['createdAt'] as Timestamp)?.toDate() ?? new Date(),
    updatedAt: (data['updatedAt'] as Timestamp)?.toDate() ?? new Date(),
  };
}
