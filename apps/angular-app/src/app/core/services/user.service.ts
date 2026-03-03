import { inject, Injectable } from '@angular/core';
import { collection, doc, getDoc, setDoc, Timestamp } from 'firebase/firestore';
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
    };
  }

  async createUser(user: User): Promise<void> {
    const ref = doc(collection(this.firestore, FIRESTORE_COLLECTIONS.USERS), user.uid);
    await setDoc(ref, {
      uid: user.uid,
      first_name: user.firstName,
      last_name: user.lastName,
      nickname: user.nickname,
      email: user.email,
      birthdate: Timestamp.fromDate(user.birthdate),
      role: user.role,
      created_at: Timestamp.fromDate(user.createdAt),
      updated_at: Timestamp.fromDate(user.updatedAt),
    });
  }
}
