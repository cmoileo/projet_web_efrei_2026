/**
 * @component FormFieldComponent
 * @description Molecule formulaire : label + input projeté + message d'erreur ou hint.
 * Utilise mat-form-field d'Angular Material 3 pour l'accessibilité et les animations.
 * L'input natif doit être projeté avec la directive `matInput`.
 *
 * @example
 * <app-form-field label="Adresse email" hint="Jamais partagée" [error]="emailControl.errors?.['required'] ? 'Champ requis' : ''">
 *   <input matInput type="email" [formControl]="emailControl" />
 * </app-form-field>
 */
import {
  ChangeDetectionStrategy,
  Component,
  input,
  model,
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';

@Component({
  selector: 'app-form-field',
  standalone: true,
  imports: [CommonModule, MatFormFieldModule, MatInputModule],
  templateUrl: './form-field.component.html',
  styleUrl: './form-field.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class FormFieldComponent {
  /** Label affiché au dessus de l'input */
  label = input<string>('');
  /**
   * Message d'erreur. Si non vide, affiche en rouge.
   * Passer une chaîne vide pour masquer l'erreur.
   */
  error = input<string>('');
  /** Message d'aide sous l'input (masqué si une erreur est présente) */
  hint = input<string>('');
  /** Marque le champ comme requis (ajoute un astérisque au label) */
  required = input<boolean>(false);
}
