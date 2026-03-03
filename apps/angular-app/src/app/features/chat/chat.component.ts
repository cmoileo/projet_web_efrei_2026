import { ChangeDetectionStrategy, Component } from '@angular/core';
import { LucideAngularModule, MessageCircle } from 'lucide-angular';

@Component({
  selector: 'app-chat',
  standalone: true,
  imports: [LucideAngularModule],
  templateUrl: './chat.component.html',
  styleUrl: './chat.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ChatComponent {
  protected readonly MessageCircleIcon = MessageCircle;
}
