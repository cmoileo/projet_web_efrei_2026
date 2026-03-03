import { inject, Injectable } from '@angular/core';
import { collection, doc, getDocs, getDoc, query, setDoc, Timestamp, where } from 'firebase/firestore';
import { FIREBASE_FIRESTORE } from '../tokens/firebase.tokens';
import { FIRESTORE_COLLECTIONS } from '../constants/firestore-collections';
import type { User } from '../models/user.model';

@Injectable({ providedIn: 'root' })
export class UserService {
  private readonly firestore = inject(FIREBASE_FIRESTORE);

  async getUser(uid: string): Promise<User | null> {
    const ref = doc(collection(this.firestore, FIRESTORE_COLLECTIONS.USERS), uid);
    const snap = await getDoc(ref);
    if (!snap.exists()) return null;
    const data = snap.data();
    return {
      uid: snap.id,
      firstName: data['first_name'] as string,
      lastName: data['last_name'] as string,
      nickname: data['nickname'] as string,
      email: data['email'] as string,
      birthdate: (data['birthdate'] as Timestamp).toDate(),
      role: data['role'] as 'student' | 'volunteer',
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
      volunteerId: data['volunteer_id'] as string | undefined,
    };
  }

  async createUser(user: User): Promise<void> {
    const ref = doc(collection(this.firestore, FIRESTORE_COLLECTIONS.USERS), user.uid);
    const data: Record<string, unknown> = {
      uid: user.uid,
      first_name: user.firstName,
      last_name: user.lastName,
      nickname: user.nickname,
      email: user.email,
      birthdate: Timestamp.fromDate(user.birthdate),
      role: user.role,
      created_at: Timestamp.fromDate(user.createdAt),
      updated_at: Timestamp.fromDate(user.updatedAt),
    };
    if (user.role === 'student') {
      data['volunteer_id'] = user.volunteerId ?? null;
    }
    await setDoc(ref, data);
  }

  async getRandomVolunteer(): Promise<User | null> {
    const q = query(
      collection(this.firestore, FIRESTORE_COLLECTIONS.USERS),
      where('role', '==', 'volunteer'),
    );
    const snap = await getDocs(q);
    if (snap.empty) return null;
    const docs = snap.docs;
    const randomDoc = docs[Math.floor(Math.random() * docs.length)];
    const data = randomDoc.data();
    return {
      uid: randomDoc.id,
      firstName: data['first_name'] as string,
      lastName: data['last_name'] as string,
      nickname: data['nickname'] as string,
      email: data['email'] as string,
      birthdate: (data['birthdate'] as Timestamp).toDate(),
      role: 'volunteer',
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
    };
  }

  async getStudentsForVolunteer(volunteerId: string): Promise<User[]> {
    const q = query(
      collection(this.firestore, FIRESTORE_COLLECTIONS.USERS),
      where('role', '==', 'student'),
      where('volunteer_id', '==', volunteerId),
    );
    const snap = await getDocs(q);
    return snap.docs.map((d) => {
      const data = d.data();
      return {
        uid: d.id,
        firstName: data['first_name'] as string,
        lastName: data['last_name'] as string,
        nickname: data['nickname'] as string,
        email: data['email'] as string,
        birthdate: (data['birthdate'] as Timestamp).toDate(),
        role: 'student' as const,
        createdAt: (data['created_at'] as Timestamp).toDate(),
        updatedAt: (data['updated_at'] as Timestamp).toDate(),
        volunteerId: data['volunteer_id'] as string,
      };
    });
  }
}
