export type TaskFirestoreStatus = 'todo' | 'in_progress' | 'done';

export type Task = {
  id: string;
  title: string;
  description: string;
  dueDate: Date;
  status: TaskFirestoreStatus;
  assignedTo: string;
  createdBy: string;
  createdAt: Date;
  updatedAt: Date;
};

export type CreateTaskPayload = {
  title: string;
  description: string;
  dueDate: Date;
  assignedTo: string;
  createdBy: string;
};

export type UpdateTaskPayload = {
  title?: string;
  description?: string;
  dueDate?: Date;
  status?: TaskFirestoreStatus;
  assignedTo?: string;
};

export const TASK_STATUS_OPTIONS: { value: TaskFirestoreStatus; label: string }[] = [
  { value: 'todo', label: 'À faire' },
  { value: 'in_progress', label: 'En cours' },
  { value: 'done', label: 'Terminée' },
];
