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
import { Router, RouterLink } from '@angular/router';
import { LucideAngularModule, Eye, EyeOff, Mail, Lock, AlertCircle } from 'lucide-angular';
import { BtnComponent, FormFieldComponent, InputComponent } from '@/shared/ui';
import { AuthService } from '../../../../core/services/auth.service';

function emailValidator(control: AbstractControl): ValidationErrors | null {
  const val = control.value as string;
  if (!val) return null;
  return /^[^@]+@[^@]+\.[^@]+$/.test(val) ? null : { email: true };
}

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [
    ReactiveFormsModule,
    RouterLink,
    LucideAngularModule,
    BtnComponent,
    FormFieldComponent,
    InputComponent,
  ],
  templateUrl: './login.component.html',
  styleUrl: './login.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class LoginComponent {
  private readonly fb = inject(FormBuilder);
  private readonly authService = inject(AuthService);
  private readonly router = inject(Router);

  protected readonly EyeIcon = Eye;
  protected readonly EyeOffIcon = EyeOff;
  protected readonly MailIcon = Mail;
  protected readonly LockIcon = Lock;
  protected readonly AlertCircleIcon = AlertCircle;

  protected readonly passwordVisible = signal(false);
  protected readonly firebaseError = this.authService.error;
  protected readonly isLoading = this.authService.isLoading;

  protected readonly form = this.fb.nonNullable.group({
    email: ['', [Validators.required, emailValidator]],
    password: ['', [Validators.required]],
  });

  protected togglePasswordVisibility(): void {
    this.passwordVisible.update((v) => !v);
  }

  protected getEmailError(): string {
    const ctrl = this.form.controls.email;
    if (!ctrl.touched) return '';
    if (ctrl.hasError('required')) return "L'email est requis.";
    if (ctrl.hasError('email')) return "Format d'email invalide.";
    return '';
  }

  protected getPasswordError(): string {
    const ctrl = this.form.controls.password;
    if (!ctrl.touched) return '';
    if (ctrl.hasError('required')) return 'Le mot de passe est requis.';
    return '';
  }

  protected async onSubmit(): Promise<void> {
    this.form.markAllAsTouched();
    if (this.form.invalid) return;
    this.authService.clearError();
    try {
      await this.authService.login(
        this.form.controls.email.value,
        this.form.controls.password.value,
      );
      await this.router.navigate(['/dashboard']);
    } catch {
    }
  }
}
