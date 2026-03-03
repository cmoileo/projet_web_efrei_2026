import {
  ChangeDetectionStrategy,
  Component,
  inject,
  OnInit,
  signal,
} from '@angular/core';
import { MatDialogRef, MAT_DIALOG_DATA, MatDialogModule } from '@angular/material/dialog';
import { MatButtonModule } from '@angular/material/button';
import { UserService } from '../../../../core/services/user.service';
import { ConversationService } from '../../services/conversation.service';
import { Router } from '@angular/router';
import type { User } from '../../../../core/models/user.model';

type DialogData = { benevoleId: string };

@Component({
  selector: 'app-new-direct-conversation-modal',
  standalone: true,
  imports: [MatDialogModule, MatButtonModule],
  templateUrl: './new-direct-conversation-modal.component.html',
  styleUrl: './new-direct-conversation-modal.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class NewDirectConversationModalComponent implements OnInit {
  private readonly dialogRef = inject(MatDialogRef<NewDirectConversationModalComponent>);
  private readonly data: DialogData = inject(MAT_DIALOG_DATA);
  private readonly userService = inject(UserService);
  private readonly conversationService = inject(ConversationService);
  private readonly router = inject(Router);

  protected readonly students = signal<User[]>([]);
  protected readonly selectedStudentId = signal<string | null>(null);
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

  protected selectStudent(uid: string): void {
    this.selectedStudentId.set(uid);
  }

  protected async onConfirm(): Promise<void> {
    const eleveId = this.selectedStudentId();
    if (!eleveId) return;
    this.submitting.set(true);
    try {
      const id = await this.conversationService.createDirectConversation(
        this.data.benevoleId,
        eleveId,
      );
      this.dialogRef.close();
      await this.router.navigate(['/chat', id]);
    } catch {
      this.error.set('Impossible de créer la conversation.');
      this.submitting.set(false);
    }
  }

  protected onCancel(): void {
    this.dialogRef.close();
  }
}
