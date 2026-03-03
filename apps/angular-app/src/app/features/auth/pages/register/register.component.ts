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
  ValidatorFn,
  Validators,
} from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatDatepickerModule } from '@angular/material/datepicker';
import { MatButtonToggleModule } from '@angular/material/button-toggle';
import {
  LucideAngularModule,
  Eye,
  EyeOff,
  Mail,
  Lock,
  User,
  AtSign,
  Calendar,
  AlertCircle,
} from 'lucide-angular';
import { BtnComponent, FormFieldComponent, InputComponent } from '@/shared/ui';
import { AuthService } from '../../../../core/services/auth.service';
import type { UserRole } from '../../../../core/models/user.model';

function emailValidator(control: AbstractControl): ValidationErrors | null {
  const val = control.value as string;
  if (!val) return null;
  return /^[^@]+@[^@]+\.[^@]+$/.test(val) ? null : { email: true };
}

function nameValidator(control: AbstractControl): ValidationErrors | null {
  const val = control.value as string;
  if (!val) return null;
  return /^[a-zA-ZÀ-ÿ\-' ]+$/.test(val) ? null : { name: true };
}

function nicknameValidator(control: AbstractControl): ValidationErrors | null {
  const val = control.value as string;
  if (!val) return null;
  return /^[a-zA-Z0-9_]+$/.test(val) ? null : { nickname: true };
}

function passwordStrengthValidator(
  control: AbstractControl,
): ValidationErrors | null {
  const val = control.value as string;
  if (!val) return null;
  const errors: ValidationErrors = {};
  if (!/[A-Z]/.test(val)) errors['noUppercase'] = true;
  if (!/[0-9]/.test(val)) errors['noDigit'] = true;
  return Object.keys(errors).length ? errors : null;
}

function passwordMatchValidator(group: AbstractControl): ValidationErrors | null {
  const password = group.get('password')?.value as string;
  const confirm = group.get('passwordConfirm')?.value as string;
  if (!confirm) return null;
  return password === confirm ? null : { passwordMismatch: true };
}

function ageRangeValidator(min: number, max: number): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    const val = control.value as Date | null;
    if (!val) return null;
    const now = new Date();
    let age =
      now.getFullYear() -
      val.getFullYear() -
      (now.getMonth() < val.getMonth() ||
      (now.getMonth() === val.getMonth() && now.getDate() < val.getDate())
        ? 1
        : 0);
    if (age < min) return { ageTooYoung: { min } };
    if (age > max) return { ageTooOld: { max } };
    return null;
  };
}

@Component({
  selector: 'app-register',
  standalone: true,
  imports: [
    ReactiveFormsModule,
    RouterLink,
    MatFormFieldModule,
    MatInputModule,
    MatDatepickerModule,
    MatButtonToggleModule,
    LucideAngularModule,
    BtnComponent,
    FormFieldComponent,
    InputComponent,
  ],
  templateUrl: './register.component.html',
  styleUrl: './register.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class RegisterComponent {
  private readonly fb = inject(FormBuilder);
  private readonly authService = inject(AuthService);
  private readonly router = inject(Router);

  protected readonly EyeIcon = Eye;
  protected readonly EyeOffIcon = EyeOff;
  protected readonly MailIcon = Mail;
  protected readonly LockIcon = Lock;
  protected readonly UserIcon = User;
  protected readonly AtSignIcon = AtSign;
  protected readonly CalendarIcon = Calendar;
  protected readonly AlertCircleIcon = AlertCircle;

  protected readonly passwordVisible = signal(false);
  protected readonly passwordConfirmVisible = signal(false);
  protected readonly firebaseError = this.authService.error;
  protected readonly isLoading = this.authService.isLoading;

  protected readonly minBirthdate = new Date(
    new Date().getFullYear() - 25,
    new Date().getMonth(),
    new Date().getDate(),
  );
  protected readonly maxBirthdate = new Date(
    new Date().getFullYear() - 10,
    new Date().getMonth(),
    new Date().getDate(),
  );

  protected readonly form = this.fb.nonNullable.group(
    {
      firstName: [
        '',
        [
          Validators.required,
          Validators.minLength(2),
          Validators.maxLength(50),
          nameValidator,
        ],
      ],
      lastName: [
        '',
        [
          Validators.required,
          Validators.minLength(2),
          Validators.maxLength(50),
          nameValidator,
        ],
      ],
      nickname: [
        '',
        [
          Validators.required,
          Validators.minLength(3),
          Validators.maxLength(20),
          nicknameValidator,
        ],
      ],
      email: ['', [Validators.required, emailValidator]],
      birthdate: [null as Date | null, [Validators.required, ageRangeValidator(10, 25)]],
      role: ['student' as UserRole],
      password: [
        '',
        [
          Validators.required,
          Validators.minLength(8),
          passwordStrengthValidator,
        ],
      ],
      passwordConfirm: ['', [Validators.required]],
    },
    { validators: passwordMatchValidator },
  );

  protected togglePasswordVisibility(): void {
    this.passwordVisible.update((v) => !v);
  }

  protected togglePasswordConfirmVisibility(): void {
    this.passwordConfirmVisible.update((v) => !v);
  }

  protected getFirstNameError(): string {
    const ctrl = this.form.controls.firstName;
    if (!ctrl.touched) return '';
    if (ctrl.hasError('required')) return 'Le prénom est requis.';
    if (ctrl.hasError('minlength') || ctrl.hasError('maxlength')) return 'Entre 2 et 50 caractères.';
    if (ctrl.hasError('name')) return 'Lettres uniquement.';
    return '';
  }

  protected getLastNameError(): string {
    const ctrl = this.form.controls.lastName;
    if (!ctrl.touched) return '';
    if (ctrl.hasError('required')) return 'Le nom est requis.';
    if (ctrl.hasError('minlength') || ctrl.hasError('maxlength')) return 'Entre 2 et 50 caractères.';
    if (ctrl.hasError('name')) return 'Lettres uniquement.';
    return '';
  }

  protected getNicknameError(): string {
    const ctrl = this.form.controls.nickname;
    if (!ctrl.touched) return '';
    if (ctrl.hasError('required')) return 'Le pseudo est requis.';
    if (ctrl.hasError('minlength') || ctrl.hasError('maxlength')) return 'Entre 3 et 20 caractères.';
    if (ctrl.hasError('nickname')) return "Alphanumérique et _ uniquement, pas d'espaces.";
    return '';
  }

  protected getEmailError(): string {
    const ctrl = this.form.controls.email;
    if (!ctrl.touched) return '';
    if (ctrl.hasError('required')) return "L'email est requis.";
    if (ctrl.hasError('email')) return "Format d'email invalide.";
    return '';
  }

  protected getBirthdateError(): string {
    const ctrl = this.form.controls.birthdate;
    if (!ctrl.touched) return '';
    if (ctrl.hasError('required') || ctrl.hasError('matDatepickerParse')) return 'La date de naissance est requise.';
    if (ctrl.hasError('ageTooYoung')) return 'Âge minimum : 10 ans.';
    if (ctrl.hasError('ageTooOld')) return 'Âge maximum : 25 ans.';
    if (ctrl.hasError('matDatepickerMin')) return 'Âge maximum : 25 ans.';
    if (ctrl.hasError('matDatepickerMax')) return 'Âge minimum : 10 ans.';
    return '';
  }

  protected getPasswordError(): string {
    const ctrl = this.form.controls.password;
    if (!ctrl.touched) return '';
    if (ctrl.hasError('required')) return 'Le mot de passe est requis.';
    if (ctrl.hasError('minlength')) return 'Minimum 8 caractères.';
    if (ctrl.hasError('noUppercase')) return 'Au moins une majuscule requise.';
    if (ctrl.hasError('noDigit')) return 'Au moins un chiffre requis.';
    return '';
  }

  protected getPasswordConfirmError(): string {
    const ctrl = this.form.controls.passwordConfirm;
    if (!ctrl.touched) return '';
    if (ctrl.hasError('required')) return 'La confirmation est requise.';
    if (this.form.hasError('passwordMismatch')) return 'Les mots de passe ne correspondent pas.';
    return '';
  }

  protected async onSubmit(): Promise<void> {
    this.form.markAllAsTouched();
    if (this.form.invalid) return;
    this.authService.clearError();
    const value = this.form.getRawValue();
    try {
      await this.authService.register({
        email: value.email,
        password: value.password,
        firstName: value.firstName,
        lastName: value.lastName,
        nickname: value.nickname,
        birthdate: value.birthdate!,
        role: value.role,
      });
      await this.router.navigate(['/dashboard']);
    } catch {
    }
  }
}
