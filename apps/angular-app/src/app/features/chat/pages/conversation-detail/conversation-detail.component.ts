import {
  ChangeDetectionStrategy,
  Component,
  computed,
  DestroyRef,
  effect,
  inject,
  OnInit,
  signal,
} from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { switchMap, Subject } from 'rxjs';
import { LucideAngularModule, ArrowLeft, Send, ChevronsUp } from 'lucide-angular';
import { AuthService } from '../../../../core/services/auth.service';
import { UserService } from '../../../../core/services/user.service';
import { ConversationService } from '../../services/conversation.service';
import { MessageBubbleComponent } from '../../components/message-bubble/message-bubble.component';
import type { Conversation } from '../../models/conversation.model';
import type { Message } from '../../models/message.model';
import type { User } from '../../../../core/models/user.model';

@Component({
  selector: 'app-conversation-detail',
  standalone: true,
  imports: [LucideAngularModule, MessageBubbleComponent],
  templateUrl: './conversation-detail.component.html',
  styleUrl: './conversation-detail.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ConversationDetailComponent implements OnInit {
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);
  private readonly authService = inject(AuthService);
  private readonly userService = inject(UserService);
  private readonly conversationService = inject(ConversationService);
  private readonly destroyRef = inject(DestroyRef);

  protected readonly ArrowLeftIcon = ArrowLeft;
  protected readonly SendIcon = Send;
  protected readonly ChevronsUpIcon = ChevronsUp;

  protected readonly conversationId = this.route.snapshot.paramMap.get('id')!;
  protected readonly messageInput = signal('');
  protected readonly sending = signal(false);
  protected readonly messageLimit = signal(30);
  protected readonly users = signal<Map<string, User>>(new Map());
  protected readonly conversation = signal<Conversation | null>(null);
  protected readonly messages = signal<Message[]>([]);

  private readonly limitSubject = new Subject<number>();

  protected readonly hasMore = computed(
    () => this.messages().length >= this.messageLimit(),
  );

  protected readonly displayTitle = computed(() => {
    const conv = this.conversation();
    if (!conv) return '';
    if (conv.name) return conv.name;
    const userId = this.authService.currentUser()?.uid ?? '';
    const otherId = conv.members.find((m) => m !== userId);
    if (!otherId) return 'Conversation';
    const user = this.users().get(otherId);
    return user ? `${user.firstName} ${user.lastName}` : 'Conversation';
  });

  constructor() {
    effect(() => {
      const conv = this.conversation();
      if (conv) this._loadMissingUsers(conv.members);
    });

    effect(() => {
      const msgs = this.messages();
      const userId = this.authService.currentUser()?.uid;
      if (!userId || msgs.length === 0) return;
      const unreadIds = msgs
        .filter((m) => !m.readBy.includes(userId))
        .map((m) => m.id);
      if (unreadIds.length === 0) return;
      this.conversationService
        .markAsRead(this.conversationId, userId, unreadIds)
        .catch(() => {});
    });
  }

  ngOnInit(): void {
    this.conversationService
      .getConversationById(this.conversationId)
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe((conv) => this.conversation.set(conv));

    this.limitSubject
      .pipe(
        switchMap((lim) => this.conversationService.getMessages(this.conversationId, lim)),
        takeUntilDestroyed(this.destroyRef),
      )
      .subscribe((msgs) => this.messages.set(msgs));

    this.limitSubject.next(this.messageLimit());
  }

  private async _loadMissingUsers(memberIds: string[]): Promise<void> {
    const current = this.users();
    const missing = memberIds.filter((uid) => !current.has(uid));
    if (missing.length === 0) return;
    const fetched = await Promise.all(missing.map((uid) => this.userService.getUser(uid)));
    const updated = new Map(current);
    fetched.forEach((user, i) => {
      if (user) updated.set(missing[i], user);
    });
    this.users.set(updated);
  }

  protected async onSend(): Promise<void> {
    const content = this.messageInput().trim();
    if (!content || this.sending()) return;
    const userId = this.authService.currentUser()?.uid;
    if (!userId) return;
    this.sending.set(true);
    this.messageInput.set('');
    try {
      await this.conversationService.sendMessage(this.conversationId, userId, content);
    } catch {
      this.messageInput.set(content);
    } finally {
      this.sending.set(false);
    }
  }

  protected onKeydown(event: KeyboardEvent): void {
    if (event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault();
      this.onSend();
    }
  }

  protected onInputChange(event: Event): void {
    this.messageInput.set((event.target as HTMLTextAreaElement).value);
  }

  protected loadMore(): void {
    const next = this.messageLimit() + 30;
    this.messageLimit.set(next);
    this.limitSubject.next(next);
  }

  protected goBack(): void {
    this.router.navigate(['/chat']);
  }

  protected showAvatar(index: number): boolean {
    const msgs = this.messages();
    if (index === msgs.length - 1) return true;
    return msgs[index + 1]?.senderId !== msgs[index].senderId;
  }

  protected isOwn(msg: Message): boolean {
    return msg.senderId === this.authService.currentUser()?.uid;
  }

  protected get allMembers(): string[] {
    return this.conversation()?.members ?? [];
  }
}
