/**
 * @component InputComponent
 * @description Champ de saisie atomique stylé avec les tokens Learn@Home.
 * Implémente ControlValueAccessor pour intégration avec les Reactive Forms.
 *
 * Pour un champ avec label et message d'erreur, utiliser `app-form-field` (molecule).
 *
 * @example
 * <!-- Standalone -->
 * <app-input type="search" placeholder="Rechercher..." />
 *
 * <!-- Avec Reactive Forms -->
 * <app-input type="email" [formControl]="emailControl" />
 */
import {
  ChangeDetectionStrategy,
  Component,
  ElementRef,
  forwardRef,
  input,
  signal,
  viewChild,
} from '@angular/core';
import { ControlValueAccessor, NG_VALUE_ACCESSOR, ReactiveFormsModule } from '@angular/forms';
import { LucideAngularModule, type LucideIconData } from 'lucide-angular';

@Component({
  selector: 'app-input',
  standalone: true,
  imports: [ReactiveFormsModule, LucideAngularModule],
  templateUrl: './input.component.html',
  styleUrl: './input.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
  providers: [
    {
      provide: NG_VALUE_ACCESSOR,
      useExisting: forwardRef(() => InputComponent),
      multi: true,
    },
  ],
})
export class InputComponent implements ControlValueAccessor {
  /** Type HTML de l'input */
  type = input<string>('text');
  /** Placeholder */
  placeholder = input<string>('');
  /** Désactive l'input */
  disabled = input<boolean>(false);
  /** Icône Lucide optionnelle (affichée à gauche de l'input) */
  prefixIcon = input<LucideIconData | undefined>(undefined);
  /** Attribut autocomplete */
  autocomplete = input<string>('off');
  /** ID HTML (pour l'association avec un label externe) */
  inputId = input<string | undefined>(undefined);

  protected readonly inputRef = viewChild<ElementRef<HTMLInputElement>>('inputEl');
  protected readonly internalValue = signal<string>('');
  protected readonly isDisabled = signal<boolean>(false);

  private onChange: (value: string) => void = () => undefined;
  private onTouched: () => void = () => undefined;

  // ─── ControlValueAccessor ─────────────────────────────
  writeValue(value: string): void {
    this.internalValue.set(value ?? '');
  }

  registerOnChange(fn: (value: string) => void): void {
    this.onChange = fn;
  }

  registerOnTouched(fn: () => void): void {
    this.onTouched = fn;
  }

  setDisabledState(isDisabled: boolean): void {
    this.isDisabled.set(isDisabled);
  }

  protected onInput(event: Event): void {
    const value = (event.target as HTMLInputElement).value;
    this.internalValue.set(value);
    this.onChange(value);
  }

  protected onBlur(): void {
    this.onTouched();
  }
}
