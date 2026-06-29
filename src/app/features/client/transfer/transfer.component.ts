import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { AuthService } from '../../../core/services/auth.service';
import { WalletApiService } from '../../../core/services/wallet-api.service';
import { BalanceStore } from '../../../core/services/balance.store';
import { NotificationService } from '../../../core/services/notification.service';
import { XofPipe } from '../../../shared/pipes/xof.pipe';
import { phoneValidator, differentPhoneValidator } from '../../../shared/validators/phone.validator';

@Component({
  selector: 'app-transfer',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, XofPipe],
  template: `
    <div class="transfer-page">
      <h2>💸 Transfert d'argent</h2>
      <div class="transfer-card">
        <form [formGroup]="transferForm" (ngSubmit)="onSubmit()">
          <div class="form-group">
            <label for="destination">Numéro destinataire</label>
            <input id="destination" type="tel" formControlName="destination" placeholder="77 XXX XX XX" [class.error]="isFieldInvalid('destination')" />
            <span class="error-msg" *ngIf="isFieldInvalid('destination') && transferForm.get('destination')?.hasError('required')">Le numéro destinataire est requis</span>
            <span class="error-msg" *ngIf="isFieldInvalid('destination') && transferForm.get('destination')?.hasError('invalidPhone')">Numéro invalide</span>
            <span class="error-msg" *ngIf="transferForm.hasError('samePhone')">Vous ne pouvez pas transférer à votre propre numéro</span>
          </div>
          <div class="form-group">
            <label for="amount">Montant</label>
            <div class="amount-input"><input id="amount" type="number" formControlName="amount" placeholder="0" [class.error]="isFieldInvalid('amount')" /><span class="currency">XOF</span></div>
            <span class="error-msg" *ngIf="isFieldInvalid('amount') && transferForm.get('amount')?.hasError('required')">Le montant est requis</span>
            <span class="error-msg" *ngIf="isFieldInvalid('amount') && transferForm.get('amount')?.hasError('min')">Le montant doit être supérieur à 0</span>
          </div>
          <div class="form-group">
            <label for="description">Description (optionnel)</label>
            <input id="description" type="text" formControlName="description" placeholder="Ex: Remboursement déjeuner" />
          </div>
          <div class="balance-info">Solde disponible : <strong>{{ balanceStore.balance() | xof }}</strong></div>
          <button type="submit" class="btn-transfer" [disabled]="transferForm.invalid || loading">{{ loading ? 'Envoi en cours...' : 'Envoyer' }}</button>
        </form>
      </div>
    </div>
  `,
  styles: [`
    .transfer-page { max-width: 500px; margin: 0 auto; }
    h2 { color: #1a237e; margin-bottom: 1.5rem; }
    .transfer-card { background: white; border-radius: 16px; padding: 2rem; box-shadow: 0 4px 16px rgba(0,0,0,0.08); }
    .form-group { margin-bottom: 1.5rem; }
    label { display: block; margin-bottom: 0.5rem; font-weight: 500; color: #333; }
    input { width: 100%; padding: 0.75rem 1rem; border: 2px solid #e0e0e0; border-radius: 8px; font-size: 1rem; box-sizing: border-box; }
    input:focus { outline: none; border-color: #1a237e; }
    input.error { border-color: #f44336; }
    .error-msg { color: #f44336; font-size: 0.8rem; margin-top: 0.25rem; display: block; }
    .amount-input { position: relative; display: flex; align-items: center; }
    .amount-input input { padding-right: 4rem; }
    .currency { position: absolute; right: 1rem; color: #666; font-weight: 500; }
    .balance-info { background: #e8eaf6; padding: 0.75rem 1rem; border-radius: 8px; margin-bottom: 1.5rem; font-size: 0.9rem; color: #1a237e; }
    .btn-transfer { width: 100%; padding: 0.85rem; background: linear-gradient(135deg, #1a237e, #3949ab); color: white; border: none; border-radius: 8px; font-size: 1.05rem; font-weight: 600; cursor: pointer; }
    .btn-transfer:disabled { opacity: 0.5; cursor: not-allowed; }
  `]
})
export class TransferComponent {
  private fb = inject(FormBuilder);
  private authService = inject(AuthService);
  private walletApi = inject(WalletApiService);
  private notification = inject(NotificationService);
  balanceStore = inject(BalanceStore);
  loading = false;
  private currentPhone = this.authService.getPhone();

  transferForm = this.fb.group({
    destination: ['', [Validators.required, phoneValidator()]],
    amount: [null as number | null, [Validators.required, Validators.min(1)]],
    description: ['']
  }, { validators: differentPhoneValidator(this.currentPhone) });

  isFieldInvalid(field: string): boolean { const c = this.transferForm.get(field); return !!(c?.touched && c?.invalid); }

  onSubmit(): void {
    if (this.transferForm.invalid) return;
    this.loading = true;
    const { destination, amount, description } = this.transferForm.value;
    this.walletApi.transfer({ senderPhone: this.currentPhone, receiverPhone: destination!, amount: amount!, description: description || undefined }).subscribe({
      next: () => { this.notification.success(`Transfert de ${amount} XOF envoyé !`); this.balanceStore.refresh(this.currentPhone); this.transferForm.reset(); this.loading = false; },
      error: () => { this.loading = false; }
    });
  }
}
