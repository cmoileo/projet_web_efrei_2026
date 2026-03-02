/**
 * @component ShowcaseModalComponent
 * @description Composant de démonstration utilisé dans le showcase UI.
 * Illustre l'utilisation typique d'une modal avec header, body et footer.
 */
import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';
import { BtnComponent, ModalComponent } from './shared/ui/index';

@Component({
  selector: 'app-showcase-modal',
  standalone: true,
  imports: [BtnComponent, ModalComponent],
  template: `
    <app-modal title="Exemple de modal" size="md" (closeModal)="close()">
      <p>Voici un exemple de contenu dans une modal Learn&#64;Home.</p>
      <p>Elle prend en charge le header, le corps scrollable et le footer avec actions.</p>

      <div actions>
        <app-btn variant="ghost" (btnClick)="close()">Annuler</app-btn>
        <app-btn variant="primary" (btnClick)="confirm()">Confirmer</app-btn>
      </div>
    </app-modal>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ShowcaseModalComponent {
  private readonly dialogRef = inject(MatDialogRef<ShowcaseModalComponent>);
  protected readonly data = inject(MAT_DIALOG_DATA, { optional: true });

  protected close(): void {
    this.dialogRef.close(null);
  }

  protected confirm(): void {
    this.dialogRef.close(true);
  }
}
