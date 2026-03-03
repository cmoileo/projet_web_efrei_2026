export type UserRole = 'student' | 'volunteer';

export type User = {
  uid: string;
  firstName: string;
  lastName: string;
  nickname: string;
  email: string;
  birthdate: Date;
  role: UserRole;
  createdAt: Date;
  updatedAt: Date;
};
