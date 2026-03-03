import {
  ChangeDetectionStrategy,
  Component,
  computed,
  DestroyRef,
  inject,
  OnInit,
  signal,
} from '@angular/core';
import { Router } from '@angular/router';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { MatDialog } from '@angular/material/dialog';
import { LucideAngularModule, MessageCircle, User, Users } from 'lucide-angular';
import { AuthService } from '../../core/services/auth.service';
import { UserService } from '../../core/services/user.service';
import { ConversationService } from './services/conversation.service';
import { ConversationTileComponent } from './components/conversation-tile/conversation-tile.component';
import { NewDirectConversationModalComponent } from './components/new-direct-conversation-modal/new-direct-conversation-modal.component';
import { NewGroupConversationModalComponent } from './components/new-group-conversation-modal/new-group-conversation-modal.component';
import type { Conversation } from './models/conversation.model';
import type { User as UserModel } from '../../core/models/user.model';

@Component({
  selector: 'app-chat',
  standalone: true,
  imports: [LucideAngularModule, ConversationTileComponent],
  templateUrl: './chat.component.html',
  styleUrl: './chat.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ChatComponent implements OnInit {
  private readonly authService = inject(AuthService);
  private readonly userService = inject(UserService);
  private readonly conversationService = inject(ConversationService);
  private readonly dialog = inject(MatDialog);
  private readonly router = inject(Router);
  private readonly destroyRef = inject(DestroyRef);

  protected readonly MessageCircleIcon = MessageCircle;
  protected readonly UserIcon = User;
  protected readonly UsersIcon = Users;

  protected readonly conversations = signal<Conversation[]>([]);
  protected readonly users = signal<Map<string, UserModel>>(new Map());
  protected readonly loading = signal(true);
  protected readonly error = signal<string | null>(null);

  protected readonly isVolunteer = computed(
    () => this.authService.currentUser()?.role === 'volunteer',
  );

  protected readonly conversationDisplayNames = computed(() => {
    const usersMap = this.users();
    const userId = this.authService.currentUser()?.uid ?? '';
    return new Map(
      this.conversations().map((conv) => {
        let name: string;
        if (conv.name) {
          name = conv.name;
        } else {
          const otherId = conv.members.find((m) => m !== userId);
          const user = otherId ? usersMap.get(otherId) : undefined;
          name = user ? `${user.firstName} ${user.lastName}` : 'Conversation';
        }
        return [conv.id, name];
      }),
    );
  });

  ngOnInit(): void {
    const userId = this.authService.currentUser()!.uid;
    this.conversationService
      .getConversations(userId)
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe({
        next: (convs) => {
          this.conversations.set(convs);
          this.loading.set(false);
          this._loadMissingUsers(convs);
        },
        error: () => {
          this.error.set('Impossible de charger les conversations.');
          this.loading.set(false);
        },
      });
  }

  private async _loadMissingUsers(convs: Conversation[]): Promise<void> {
    const allUids = [...new Set(convs.flatMap((c) => c.members))];
    const current = this.users();
    const missing = allUids.filter((uid) => !current.has(uid));
    if (missing.length === 0) return;
    const fetched = await Promise.all(missing.map((uid) => this.userService.getUser(uid)));
    const updated = new Map(current);
    fetched.forEach((user, i) => {
      if (user) updated.set(missing[i], user);
    });
    this.users.set(updated);
  }

  protected getDisplayName(conv: Conversation): string {
    return this.conversationDisplayNames().get(conv.id) ?? 'Conversation';
  }

  protected navigateTo(conv: Conversation): void {
    this.router.navigate(['/chat', conv.id]);
  }

  protected openNewDirectConversation(): void {
    const benevoleId = this.authService.currentUser()!.uid;
    this.dialog.open(NewDirectConversationModalComponent, {
      data: { benevoleId },
      panelClass: 'chat-dialog',
    });
  }

  protected openNewGroupConversation(): void {
    const benevoleId = this.authService.currentUser()!.uid;
    this.dialog.open(NewGroupConversationModalComponent, {
      data: { benevoleId },
      panelClass: 'chat-dialog',
    });
  }
}
