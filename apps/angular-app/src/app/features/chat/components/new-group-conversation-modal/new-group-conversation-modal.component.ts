import {
  ChangeDetectionStrategy,
  Component,
  inject,
  OnInit,
  signal,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { MatDialogRef, MAT_DIALOG_DATA, MatDialogModule } from '@angular/material/dialog';
import { MatButtonModule } from '@angular/material/button';
import { UserService } from '../../../../core/services/user.service';
import { ConversationService } from '../../services/conversation.service';
import { Router } from '@angular/router';
import type { User } from '../../../../core/models/user.model';

type DialogData = { benevoleId: string };

@Component({
  selector: 'app-new-group-conversation-modal',
  standalone: true,
  imports: [FormsModule, MatDialogModule, MatButtonModule],
  templateUrl: './new-group-conversation-modal.component.html',
  styleUrl: './new-group-conversation-modal.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class NewGroupConversationModalComponent implements OnInit {
  private readonly dialogRef = inject(MatDialogRef<NewGroupConversationModalComponent>);
  private readonly data: DialogData = inject(MAT_DIALOG_DATA);
  private readonly userService = inject(UserService);
  private readonly conversationService = inject(ConversationService);
  private readonly router = inject(Router);

  protected readonly students = signal<User[]>([]);
  protected readonly selectedIds = signal<Set<string>>(new Set());
  protected groupName = '';
  protected readonly loading = signal(true);
  protected readonly submitting = signal(false);
  protected readonly error = signal<string | null>(null);

  async ngOnInit(): Promise<void> {
    try {
      const list = await this.userService.getStudentsForVolunteer(this.data.benevoleId);
      this.students.set(list);
    } catch {
      this.error.set('Impossible de charger les élèves.');
    } finally {
      this.loading.set(false);
    }
  }

  protected toggleStudent(uid: string): void {
    const current = new Set(this.selectedIds());
    if (current.has(uid)) {
      current.delete(uid);
    } else {
      current.add(uid);
    }
    this.selectedIds.set(current);
  }

  protected isSelected(uid: string): boolean {
    return this.selectedIds().has(uid);
  }

  protected get isValid(): boolean {
    return this.groupName.trim().length > 0 && this.selectedIds().size > 0;
  }

  protected async onConfirm(): Promise<void> {
    if (!this.isValid) return;
    this.submitting.set(true);
    try {
      const id = await this.conversationService.createGroupConversation(
        this.data.benevoleId,
        this.groupName.trim(),
        [...this.selectedIds()],
      );
      this.dialogRef.close();
      await this.router.navigate(['/chat', id]);
    } catch {
      this.error.set('Impossible de créer le groupe.');
      this.submitting.set(false);
    }
  }

  protected onCancel(): void {
    this.dialogRef.close();
  }
}
