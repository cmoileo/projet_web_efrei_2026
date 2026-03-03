export type Conversation = {
  id: string;
  type: 'direct' | 'group';
  name: string | null;
  createdBy: string;
  members: string[];
  createdAt: Date;
  updatedAt: Date;
  unreadCount: number;
  lastMessage: string | null;
};
