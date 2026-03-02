/**
 * Barrel — UI Library Learn@Home
 *
 * Point d'entrée unique pour importer n'importe quel composant UI.
 *
 * @example
 * import { BtnComponent, CardComponent, ToastService } from '@/shared/ui';
 */

// ─── Types ────────────────────────────────────────────────
export * from './ui.types';

// ─── Atoms ────────────────────────────────────────────────
export { AvatarComponent } from './atoms/avatar/avatar.component';
export { BadgeComponent } from './atoms/badge/badge.component';
export { BtnComponent } from './atoms/btn/btn.component';
export { DividerComponent } from './atoms/divider/divider.component';
export { InputComponent } from './atoms/input/input.component';

// ─── Molecules ────────────────────────────────────────────
export { CardComponent } from './molecules/card/card.component';
export { FormFieldComponent } from './molecules/form-field/form-field.component';
export { MessageBubbleComponent } from './molecules/message-bubble/message-bubble.component';
export { TaskItemComponent } from './molecules/task-item/task-item.component';
export { ToastComponent } from './molecules/toast/toast.component';
export { ToastService } from './molecules/toast/toast.service';

// ─── Organisms ────────────────────────────────────────────
export { ModalComponent } from './organisms/modal/modal.component';
export { ModalService } from './organisms/modal/modal.service';
export { SidebarComponent } from './organisms/sidebar/sidebar.component';
export { TopAppBarComponent } from './organisms/top-app-bar/top-app-bar.component';
