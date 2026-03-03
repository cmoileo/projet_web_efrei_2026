import { inject, Injectable } from '@angular/core';
import {
  addDoc,
  arrayUnion,
  collection,
  doc,
  getDocs,
  limit,
  onSnapshot,
  orderBy,
  query,
  serverTimestamp,
  Timestamp,
  where,
  writeBatch,
} from 'firebase/firestore';
import { Observable } from 'rxjs';
import { FIREBASE_FIRESTORE } from '../../../core/tokens/firebase.tokens';
import { FIRESTORE_COLLECTIONS } from '../../../core/constants/firestore-collections';
import type { Conversation } from '../models/conversation.model';
import type { Message } from '../models/message.model';

@Injectable({ providedIn: 'root' })
export class ConversationService {
  private readonly firestore = inject(FIREBASE_FIRESTORE);

  getConversations(userId: string): Observable<Conversation[]> {
    return new Observable<Conversation[]>((observer) => {
      const q = query(
        collection(this.firestore, FIRESTORE_COLLECTIONS.CONVERSATIONS),
        where('members', 'array-contains', userId),
        orderBy('updatedAt', 'desc'),
      );
      const unsubscribe = onSnapshot(
        q,
        (snapshot) => {
          Promise.all(
            snapshot.docs.map(async (docSnap) => {
              const data = docSnap.data();
              const messagesSnap = await getDocs(
                collection(
                  this.firestore,
                  FIRESTORE_COLLECTIONS.CONVERSATIONS,
                  docSnap.id,
                  'messages',
                ),
              );
              const unreadCount = messagesSnap.docs.filter(
                (m) => !(m.data()['readBy'] as string[]).includes(userId),
              ).length;
              return {
                id: docSnap.id,
                type: data['type'] as 'direct' | 'group',
                name: (data['name'] as string | null) ?? null,
                createdBy: data['createdBy'] as string,
                members: data['members'] as string[],
                createdAt: (data['createdAt'] as Timestamp)?.toDate() ?? new Date(),
                updatedAt: (data['updatedAt'] as Timestamp)?.toDate() ?? new Date(),
                lastMessage: (data['lastMessage'] as string | null) ?? null,
                unreadCount,
              } satisfies Conversation;
            }),
          )
            .then((conversations) => observer.next(conversations))
            .catch((error: unknown) => observer.error(error));
        },
        (error) => observer.error(error),
      );
      return unsubscribe;
    });
  }

  getConversationById(conversationId: string): Observable<Conversation | null> {
    return new Observable<Conversation | null>((observer) => {
      const ref = doc(this.firestore, FIRESTORE_COLLECTIONS.CONVERSATIONS, conversationId);
      const unsubscribe = onSnapshot(
        ref,
        (docSnap) => {
          if (!docSnap.exists()) {
            observer.next(null);
            return;
          }
          const data = docSnap.data();
          observer.next({
            id: docSnap.id,
            type: data['type'] as 'direct' | 'group',
            name: (data['name'] as string | null) ?? null,
            createdBy: data['createdBy'] as string,
            members: data['members'] as string[],
            createdAt: (data['createdAt'] as Timestamp)?.toDate() ?? new Date(),
            updatedAt: (data['updatedAt'] as Timestamp)?.toDate() ?? new Date(),
            lastMessage: (data['lastMessage'] as string | null) ?? null,
            unreadCount: 0,
          });
        },
        (error) => observer.error(error),
      );
      return unsubscribe;
    });
  }

  getMessages(conversationId: string, messagesLimit = 30): Observable<Message[]> {
    return new Observable<Message[]>((observer) => {
      const q = query(
        collection(
          this.firestore,
          FIRESTORE_COLLECTIONS.CONVERSATIONS,
          conversationId,
          'messages',
        ),
        orderBy('sentAt', 'desc'),
        limit(messagesLimit),
      );
      const unsubscribe = onSnapshot(
        q,
        (snapshot) => {
          const messages: Message[] = snapshot.docs.map((docSnap) => {
            const data = docSnap.data();
            return {
              id: docSnap.id,
              content: data['content'] as string,
              senderId: data['senderId'] as string,
              sentAt: (data['sentAt'] as Timestamp)?.toDate() ?? new Date(),
              readBy: (data['readBy'] as string[]) ?? [],
            };
          });
          observer.next(messages);
        },
        (error) => observer.error(error),
      );
      return unsubscribe;
    });
  }

  async sendMessage(conversationId: string, senderId: string, content: string): Promise<void> {
    const batch = writeBatch(this.firestore);
    const messageRef = doc(
      collection(
        this.firestore,
        FIRESTORE_COLLECTIONS.CONVERSATIONS,
        conversationId,
        'messages',
      ),
    );
    batch.set(messageRef, {
      content,
      senderId,
      sentAt: serverTimestamp(),
      readBy: [senderId],
    });
    const conversationRef = doc(
      this.firestore,
      FIRESTORE_COLLECTIONS.CONVERSATIONS,
      conversationId,
    );
    batch.update(conversationRef, {
      updatedAt: serverTimestamp(),
      lastMessage: content,
    });
    await batch.commit();
  }

  async markAsRead(
    conversationId: string,
    userId: string,
    messageIds: string[],
  ): Promise<void> {
    if (messageIds.length === 0) return;
    const batch = writeBatch(this.firestore);
    for (const id of messageIds) {
      const ref = doc(
        this.firestore,
        FIRESTORE_COLLECTIONS.CONVERSATIONS,
        conversationId,
        'messages',
        id,
      );
      batch.update(ref, { readBy: arrayUnion(userId) });
    }
    await batch.commit();
  }

  async createDirectConversation(benevoleId: string, eleveId: string): Promise<string> {
    const existing = await getDocs(
      query(
        collection(this.firestore, FIRESTORE_COLLECTIONS.CONVERSATIONS),
        where('type', '==', 'direct'),
        where('members', 'array-contains', benevoleId),
      ),
    );
    for (const docSnap of existing.docs) {
      const members = docSnap.data()['members'] as string[];
      if (members.includes(eleveId)) return docSnap.id;
    }
    const ref = await addDoc(
      collection(this.firestore, FIRESTORE_COLLECTIONS.CONVERSATIONS),
      {
        type: 'direct',
        name: null,
        createdBy: benevoleId,
        members: [benevoleId, eleveId],
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
        lastMessage: null,
      },
    );
    return ref.id;
  }

  async createGroupConversation(
    benevoleId: string,
    name: string,
    memberIds: string[],
  ): Promise<string> {
    const members = [benevoleId, ...memberIds];
    const ref = await addDoc(
      collection(this.firestore, FIRESTORE_COLLECTIONS.CONVERSATIONS),
      {
        type: 'group',
        name,
        createdBy: benevoleId,
        members,
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
        lastMessage: null,
      },
    );
    return ref.id;
  }
}
