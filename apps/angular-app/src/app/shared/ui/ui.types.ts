// ============================================================
// Types partagés — composants UI Learn@Home
// Utilisés par tous les composants de src/app/shared/ui/
// ============================================================

// ─── Bouton ──────────────────────────────────────────────
/** Variante visuelle du bouton */
export type ButtonVariant = 'primary' | 'secondary' | 'ghost' | 'danger';

/** Taille du bouton */
export type ButtonSize = 'sm' | 'md' | 'lg';

// ─── Badge de statut ─────────────────────────────────────
/** Statut d'une tâche */
export type TaskStatus = 'todo' | 'in_progress' | 'done' | 'late';

/** Libellés affichés pour chaque statut */
export const TASK_STATUS_LABELS: Record<TaskStatus, string> = {
  todo: 'À faire',
  in_progress: 'En cours',
  done: 'Terminé',
  late: 'En retard',
} as const;

// ─── Avatar ──────────────────────────────────────────────
/** Taille de l'avatar en pixels */
export type AvatarSize = 24 | 32 | 40 | 48;

// ─── Toast ───────────────────────────────────────────────
/** Type de notification toast */
export type ToastType = 'success' | 'error' | 'warning' | 'info';

/** Données d'une notification */
export type ToastData = {
  message: string;
  type: ToastType;
  /** Durée en ms avant fermeture automatique (défaut : 4000) */
  duration?: number;
};

// ─── Navigation (Sidebar) ────────────────────────────────
/** Élément de navigation dans la sidebar */
export type NavItem = {
  /** Libellé accessible affiché */
  label: string;
  /** Route Angular (ex: '/dashboard') */
  route: string;
  /** Nom de l'icône Lucide (ex: 'layout-dashboard') */
  icon: string;
  /** Badge numérique optionnel (ex: messages non lus) */
  badge?: number;
};

// ─── Task Item ───────────────────────────────────────────
/** Tâche minimale pour l'affichage dans TaskItem */
export type TaskItem = {
  id: string;
  title: string;
  status: TaskStatus;
  /** Nom de la personne assignée */
  assignedTo?: string;
  /** Date d'échéance ISO string */
  dueDate?: string;
};

// ─── Message Bubble (Chat) ───────────────────────────────
/** Côté d'affichage d'une bulle de message */
export type MessageSide = 'me' | 'other';

// ─── Modal ───────────────────────────────────────────────
/** Taille de la modal */
export type ModalSize = 'sm' | 'md' | 'lg';

/** Configuration d'une modal */
export type ModalConfig<T = unknown> = {
  title: string;
  size?: ModalSize;
  data?: T;
};
