import { computed, inject, Injectable, OnDestroy, signal } from '@angular/core';
import {
  createUserWithEmailAndPassword,
  onAuthStateChanged,
  sendPasswordResetEmail,
  signInWithEmailAndPassword,
  signOut,
} from 'firebase/auth';
import { FIREBASE_AUTH } from '../tokens/firebase.tokens';
import { UserService } from './user.service';
import { mapFirebaseError } from '../utils/firebase-error-messages';
import type { User, UserRole } from '../models/user.model';

interface AuthState {
  user: User | null;
  loading: boolean;
  error: string | null;
}

export type RegisterParams = {
  email: string;
  password: string;
  firstName: string;
  lastName: string;
  nickname: string;
  birthdate: Date;
  role: UserRole;
};

@Injectable({ providedIn: 'root' })
export class AuthService implements OnDestroy {
  private readonly auth = inject(FIREBASE_AUTH);
  private readonly userService = inject(UserService);

  private readonly _state = signal<AuthState>({ user: null, loading: true, error: null });

  readonly currentUser = computed(() => this._state().user);
  readonly isAuthenticated = computed(() => !!this._state().user);
  readonly isLoading = computed(() => this._state().loading);
  readonly error = computed(() => this._state().error);

  private readonly _unsubscribeAuth: () => void;

  constructor() {
    this._unsubscribeAuth = onAuthStateChanged(this.auth, async (firebaseUser) => {
      if (!firebaseUser) {
        this._state.set({ user: null, loading: false, error: null });
        return;
      }
      try {
        const user = await this.userService.getUser(firebaseUser.uid);
        this._state.set({ user, loading: false, error: null });
      } catch {
        this._state.set({ user: null, loading: false, error: null });
      }
    });
  }

  ngOnDestroy(): void {
    this._unsubscribeAuth();
  }

  async login(email: string, password: string): Promise<void> {
    this._patch({ loading: true, error: null });
    try {
      const credential = await signInWithEmailAndPassword(this.auth, email, password);
      const user = await this.userService.getUser(credential.user.uid);
      this._patch({ user, loading: false });
    } catch (err: unknown) {
      const code = (err as { code?: string }).code ?? '';
      this._patch({ loading: false, error: mapFirebaseError(code) });
      throw err;
    }
  }

  async register(params: RegisterParams): Promise<void> {
    this._patch({ loading: true, error: null });
    let uid: string | undefined;
    try {
      const credential = await createUserWithEmailAndPassword(
        this.auth,
        params.email,
        params.password,
      );
      uid = credential.user.uid;
      const now = new Date();
      const newUser: User = {
        uid,
        firstName: params.firstName,
        lastName: params.lastName,
        nickname: params.nickname,
        email: params.email,
        birthdate: params.birthdate,
        role: params.role,
        createdAt: now,
        updatedAt: now,
      };
      await this.userService.createUser(newUser);
      this._patch({ user: newUser, loading: false });
    } catch (err: unknown) {
      if (uid) {
        try {
          await this.auth.currentUser?.delete();
        } catch {
        }
      }
      const code = (err as { code?: string }).code ?? '';
      this._patch({ loading: false, error: mapFirebaseError(code) });
      throw err;
    }
  }

  async sendPasswordResetEmail(email: string): Promise<void> {
    this._patch({ loading: true, error: null });
    try {
      await sendPasswordResetEmail(this.auth, email);
      this._patch({ loading: false });
    } catch (err: unknown) {
      const code = (err as { code?: string }).code ?? '';
      this._patch({ loading: false, error: mapFirebaseError(code) });
      throw err;
    }
  }

  async logout(): Promise<void> {
    await signOut(this.auth);
    this._state.set({ user: null, loading: false, error: null });
  }

  clearError(): void {
    this._state.update((s) => ({ ...s, error: null }));
  }

  private _patch(patch: Partial<AuthState>): void {
    this._state.update((s) => ({ ...s, ...patch }));
  }
}
