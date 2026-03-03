export type Message = {
  id: string;
  content: string;
  senderId: string;
  sentAt: Date;
  readBy: string[];
};
