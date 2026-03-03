import type { User } from '../../../core/models/user.model';

export type AuthState = {
  user: User | null;
  loading: boolean;
  error: string | null;
};

export const AUTH_INITIAL_STATE: AuthState = {
  user: null,
  loading: true,
  error: null,
};
