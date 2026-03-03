import {
  ChangeDetectionStrategy,
  Component,
  inject,
  signal,
} from '@angular/core';
import {
  AbstractControl,
  FormBuilder,
  ReactiveFormsModule,
  ValidationErrors,
  Validators,
} from '@angular/forms';
import { Router } from '@angular/router';
import { LucideAngularModule, Mail, AlertCircle, CheckCircle } from 'lucide-angular';
import { BtnComponent, FormFieldComponent, InputComponent } from '@/shared/ui';
import { AuthService } from '../../../../core/services/auth.service';

function emailValidator(control: AbstractControl): ValidationErrors | null {
  const val = control.value as string;
  if (!val) return null;
  return /^[^@]+@[^@]+\.[^@]+$/.test(val) ? null : { email: true };
}

@Component({
  selector: 'app-forgot-password',
  standalone: true,
  imports: [
    ReactiveFormsModule,
    LucideAngularModule,
    BtnComponent,
    FormFieldComponent,
    InputComponent,
  ],
  templateUrl: './forgot-password.component.html',
  styleUrl: './forgot-password.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ForgotPasswordComponent {
  private readonly fb = inject(FormBuilder);
  private readonly authService = inject(AuthService);
  private readonly router = inject(Router);

  protected readonly MailIcon = Mail;
  protected readonly AlertCircleIcon = AlertCircle;
  protected readonly CheckCircleIcon = CheckCircle;

  protected readonly firebaseError = this.authService.error;
  protected readonly isLoading = this.authService.isLoading;
  protected readonly emailSent = signal(false);
  protected readonly sentEmail = signal('');

  protected readonly form = this.fb.nonNullable.group({
    email: ['', [Validators.required, emailValidator]],
  });

  protected getEmailError(): string {
    const ctrl = this.form.controls.email;
    if (!ctrl.touched) return '';
    if (ctrl.hasError('required')) return "L'email est requis.";
    if (ctrl.hasError('email')) return "Format d'email invalide.";
    return '';
  }

  protected navigateToLogin(): void {
    this.router.navigate(['/auth/login']);
  }

  protected async onSubmit(): Promise<void> {
    this.form.markAllAsTouched();
    if (this.form.invalid) return;
    this.authService.clearError();
    const email = this.form.controls.email.value;
    try {
      await this.authService.sendPasswordResetEmail(email);
      this.sentEmail.set(email);
      this.emailSent.set(true);
    } catch {
    }
  }
}
