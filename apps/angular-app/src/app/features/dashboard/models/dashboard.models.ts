export type TaskSummary = {
  total: number;
  completed: number;
  inProgress: number;
};

export type EventItem = {
  id: string;
  title: string;
  date: Date;
};

export type StudentInfo = {
  id: string;
  firstName: string;
  lastName: string;
  taskCount: number;
};

export type DashboardData = {
  students: StudentInfo[];
  taskSummary: TaskSummary;
  events: EventItem[];
  unreadMessages: number;
};
