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
  taskCount: number | null;
};

export type VolunteerInfo = {
  uid: string;
  firstName: string;
  lastName: string;
};

export type DashboardUnreadMessage = {
  conversationId: string;
  senderName: string;
  excerpt: string;
  unreadCount: number;
  updatedAt: Date;
};

export type DashboardData = {
  students: StudentInfo[];
  taskSummary: TaskSummary;
  events: EventItem[];
  unreadMessages: number;
};
