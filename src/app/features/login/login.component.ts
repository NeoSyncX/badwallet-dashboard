import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { AuthService } from '../../core/services/auth.service';
import { WalletApiService } from '../../core/services/wallet-api.service';
import { NotificationService } from '../../core/services/notification.service';
import { phoneValidator } from '../../shared/validators/phone.validator';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  template: `
    <div class="login-container">
      <div class="login-card">
        <div class="login-header">
          <h1>💰 BadWallet</h1>
          <p>Connectez-vous à votre espace</p>
        </div>
        <form [formGroup]="loginForm" (ngSubmit)="onSubmit()">
          <div class="form-group">
            <label for="phone">Numéro de téléphone</label>
            <input id="phone" type="tel" formControlName="phone" placeholder="77 123 45 67" />
            <span class="error-msg" *ngIf="loginForm.get('phone')?.touched && loginForm.get('phone')?.hasError('required')">Le numéro est requis</span>
            <span class="error-msg" *ngIf="loginForm.get('phone')?.touched && loginForm.get('phone')?.hasError('invalidPhone')">Numéro invalide</span>
          </div>
          <div class="form-group">
            <label>Type de compte</label>
            <div class="role-selector">
              <button type="button" class="role-btn" [class.active]="loginForm.get('role')?.value === 'CLIENT'" (click)="setRole('CLIENT')">👤 Client</button>
              <button type="button" class="role-btn" [class.active]="loginForm.get('role')?.value === 'AGENT'" (click)="setRole('AGENT')">🏦 Agent</button>
            </div>
          </div>
          <button type="submit" class="btn-submit" [disabled]="loginForm.invalid || loading">{{ loading ? 'Connexion...' : 'Se connecter' }}</button>
        </form>
      </div>
    </div>
  `,
  styles: [`
    .login-container { display: flex; align-items: center; justify-content: center; min-height: 100vh; background: linear-gradient(135deg, #1a237e 0%, #283593 50%, #3949ab 100%); }
    .login-card { background: white; border-radius: 16px; padding: 2.5rem; width: 100%; max-width: 420px; box-shadow: 0 20px 60px rgba(0,0,0,0.3); }
    .login-header { text-align: center; margin-bottom: 2rem; }
    .login-header h1 { font-size: 2rem; color: #1a237e; margin-bottom: 0.5rem; }
    .login-header p { color: #666; }
    .form-group { margin-bottom: 1.5rem; }
    label { display: block; margin-bottom: 0.5rem; font-weight: 500; color: #333; }
    input { width: 100%; padding: 0.75rem 1rem; border: 2px solid #e0e0e0; border-radius: 8px; font-size: 1rem; box-sizing: border-box; }
    .error-msg { color: #f44336; font-size: 0.8rem; margin-top: 0.25rem; display: block; }
    .role-selector { display: flex; gap: 1rem; }
    .role-btn { flex: 1; padding: 0.75rem; border: 2px solid #e0e0e0; border-radius: 8px; background: white; cursor: pointer; font-size: 1rem; }
    .role-btn.active { border-color: #1a237e; background: #e8eaf6; color: #1a237e; font-weight: 600; }
    .btn-submit { width: 100%; padding: 0.85rem; background: linear-gradient(135deg, #1a237e, #3949ab); color: white; border: none; border-radius: 8px; font-size: 1.05rem; font-weight: 600; cursor: pointer; }
    .btn-submit:disabled { opacity: 0.5; cursor: not-allowed; }
  `]
})
export class LoginComponent {
  private fb = inject(FormBuilder);
  private authService = inject(AuthService);
  private walletApi = inject(WalletApiService);
  private notification = inject(NotificationService);
  loading = false;

  loginForm = this.fb.group({
    phone: ['', [Validators.required, phoneValidator()]],
    role: ['CLIENT' as 'CLIENT' | 'AGENT', Validators.required]
  });

  setRole(role: 'CLIENT' | 'AGENT'): void { this.loginForm.patchValue({ role }); }

  onSubmit(): void {
    if (this.loginForm.invalid) return;
    const { phone, role } = this.loginForm.value;
    this.loading = true;

    if (role === 'CLIENT') {
      this.walletApi.searchByPhone(phone!).subscribe({
        next: (wallet) => {
          const walletCode = 'WLT-' + String(wallet.id).padStart(7, '0');
          this.authService.login(phone!, 'CLIENT', walletCode, wallet.id);
          this.notification.success('Connexion réussie !');
          this.loading = false;
        },
        error: () => {
          this.notification.error('Aucun portefeuille trouvé pour ce numéro.');
          this.loading = false;  // ✅ important
        }
      });
    } else {
      // Agent : connexion directe sans API
      this.authService.login(phone!, 'AGENT');
      this.notification.success('Connexion agent réussie !');
      this.loading = false;
    }
  }
}