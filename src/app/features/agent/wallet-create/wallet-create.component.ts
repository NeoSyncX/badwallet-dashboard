import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { WalletApiService } from '../../../core/services/wallet-api.service';
import { NotificationService } from '../../../core/services/notification.service';
import { phoneValidator } from '../../../shared/validators/phone.validator';

@Component({
  selector: 'app-wallet-create',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  template: `
    <div class="create-page">
      <h2>➕ Créer un portefeuille</h2>
      <div class="form-card">
        <form [formGroup]="createForm" (ngSubmit)="onSubmit()">
          <div class="form-group"><label>Prénom</label><input type="text" formControlName="firstName" placeholder="Prénom" [class.error]="isFieldInvalid('firstName')" /><span class="error-msg" *ngIf="isFieldInvalid('firstName')">Le prénom est requis</span></div>
          <div class="form-group"><label>Nom</label><input type="text" formControlName="lastName" placeholder="Nom" [class.error]="isFieldInvalid('lastName')" /><span class="error-msg" *ngIf="isFieldInvalid('lastName')">Le nom est requis</span></div>
          <div class="form-group"><label>Téléphone</label><input type="tel" formControlName="phone" placeholder="77 123 45 67" [class.error]="isFieldInvalid('phone')" /><span class="error-msg" *ngIf="isFieldInvalid('phone') && createForm.get('phone')?.hasError('required')">Le numéro est requis</span><span class="error-msg" *ngIf="isFieldInvalid('phone') && createForm.get('phone')?.hasError('invalidPhone')">Numéro invalide</span></div>
          <div class="form-group"><label>Code PIN (optionnel)</label><input type="password" formControlName="pin" placeholder="4 chiffres" maxlength="4" /></div>
          <button type="submit" class="btn-create" [disabled]="createForm.invalid || loading">{{ loading ? 'Création...' : 'Créer le portefeuille' }}</button>
        </form>
        <div class="success-card" *ngIf="createdWallet">
          <h3>✅ Portefeuille créé !</h3>
          <p><strong>ID :</strong> {{ createdWallet.id }}</p>
          <p><strong>Client :</strong> {{ createdWallet.firstName }} {{ createdWallet.lastName }}</p>
          <p><strong>Téléphone :</strong> {{ createdWallet.phone }}</p>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .create-page { max-width: 500px; margin: 0 auto; }
    h2 { color: #1a237e; margin-bottom: 1.5rem; }
    .form-card { background: white; border-radius: 16px; padding: 2rem; box-shadow: 0 4px 16px rgba(0,0,0,0.08); }
    .form-group { margin-bottom: 1.5rem; }
    label { display: block; margin-bottom: 0.5rem; font-weight: 500; }
    input { width: 100%; padding: 0.75rem 1rem; border: 2px solid #e0e0e0; border-radius: 8px; font-size: 1rem; box-sizing: border-box; }
    input:focus { outline: none; border-color: #1a237e; }
    input.error { border-color: #f44336; }
    .error-msg { color: #f44336; font-size: 0.8rem; margin-top: 0.25rem; display: block; }
    .btn-create { width: 100%; padding: 0.85rem; background: linear-gradient(135deg, #1a237e, #3949ab); color: white; border: none; border-radius: 8px; font-size: 1.05rem; font-weight: 600; cursor: pointer; }
    .btn-create:disabled { opacity: 0.5; cursor: not-allowed; }
    .success-card { margin-top: 1.5rem; padding: 1.5rem; background: #e8f5e9; border-radius: 10px; border: 1px solid #a5d6a7; }
    .success-card h3 { color: #2e7d32; margin-bottom: 0.75rem; }
    .success-card p { margin: 0.25rem 0; }
  `]
})
export class WalletCreateComponent {
  private fb = inject(FormBuilder);
  private walletApi = inject(WalletApiService);
  private notification = inject(NotificationService);
  loading = false; createdWallet: any = null;

  createForm = this.fb.group({
    firstName: ['', Validators.required],
    lastName: ['', Validators.required],
    phone: ['', [Validators.required, phoneValidator()]],
    pin: ['']
  });

  isFieldInvalid(field: string): boolean { const c = this.createForm.get(field); return !!(c?.touched && c?.invalid); }

  onSubmit(): void {
    if (this.createForm.invalid) return;
    this.loading = true; this.createdWallet = null;
    const { firstName, lastName, phone, pin } = this.createForm.value;
    this.walletApi.createWallet({ firstName: firstName!, lastName: lastName!, phone: phone!, pin: pin || undefined }).subscribe({
      next: (wallet) => { this.createdWallet = wallet; this.notification.success('Portefeuille créé !'); this.createForm.reset(); this.loading = false; },
      error: () => { this.loading = false; }
    });
  }
}
