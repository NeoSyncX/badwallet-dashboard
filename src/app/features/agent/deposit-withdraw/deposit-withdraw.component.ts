import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { WalletApiService } from '../../../core/services/wallet-api.service';
import { NotificationService } from '../../../core/services/notification.service';
import { phoneValidator } from '../../../shared/validators/phone.validator';
import { XofPipe } from '../../../shared/pipes/xof.pipe';

@Component({
  selector: 'app-deposit-withdraw',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, XofPipe],
  template: `
    <div class="dw-page">
      <h2>💵 Dépôt & Retrait</h2>
      <div class="tabs">
        <button class="tab-btn" [class.active]="activeTab === 'deposit'" (click)="activeTab = 'deposit'">⬇️ Dépôt</button>
        <button class="tab-btn" [class.active]="activeTab === 'withdraw'" (click)="activeTab = 'withdraw'">⬆️ Retrait</button>
      </div>
      <div class="form-card" *ngIf="activeTab === 'deposit'">
        <form [formGroup]="depositForm" (ngSubmit)="onDeposit()">
          <div class="form-group"><label>Téléphone client</label><div class="search-inline"><input type="tel" formControlName="phone" placeholder="77 123 45 67" /><button type="button" (click)="searchForDeposit()" [disabled]="!depositForm.get('phone')?.valid">🔍</button></div></div>
          <div class="client-info" *ngIf="depositClient"><span>👤 {{ depositClient.firstName }} {{ depositClient.lastName }}</span><span>Solde : {{ depositClient.balance | xof }}</span></div>
          <div class="form-group"><label>Montant</label><input type="number" formControlName="amount" placeholder="0" /></div>
          <div class="form-group">
            <label>Méthode de paiement</label>
            <select formControlName="paymentMethod">
              <option value="CREDIT_CARD">💳 Carte de crédit (frais 500 XOF)</option>
              <option value="WALLET_TARGET">📱 Wallet Target (gratuit)</option>
            </select>
          </div>
          <div class="form-group"><label>Description (optionnel)</label><input type="text" formControlName="description" placeholder="Motif" /></div>
          <button type="submit" class="btn-action deposit" [disabled]="depositForm.invalid || !depositClient || loadingDeposit">{{ loadingDeposit ? 'Traitement...' : 'Effectuer le dépôt' }}</button>
        </form>
      </div>
      <div class="form-card" *ngIf="activeTab === 'withdraw'">
        <form [formGroup]="withdrawForm" (ngSubmit)="onWithdraw()">
          <div class="form-group"><label>Téléphone client</label><div class="search-inline"><input type="tel" formControlName="phone" placeholder="77 123 45 67" /><button type="button" (click)="searchForWithdraw()" [disabled]="!withdrawForm.get('phone')?.valid">🔍</button></div></div>
          <div class="client-info" *ngIf="withdrawClient"><span>👤 {{ withdrawClient.firstName }} {{ withdrawClient.lastName }}</span><span>Solde : {{ withdrawClient.balance | xof }}</span></div>
          <div class="form-group"><label>Montant</label><input type="number" formControlName="amount" placeholder="0" /></div>
          <div class="form-group"><label>Description (optionnel)</label><input type="text" formControlName="description" placeholder="Motif" /></div>
          <button type="submit" class="btn-action withdraw" [disabled]="withdrawForm.invalid || !withdrawClient || loadingWithdraw">{{ loadingWithdraw ? 'Traitement...' : 'Effectuer le retrait' }}</button>
        </form>
      </div>
    </div>
  `,
  styles: [`
    .dw-page { max-width: 550px; margin: 0 auto; }
    h2 { color: #1a237e; margin-bottom: 1.5rem; }
    .tabs { display: flex; gap: 0.5rem; margin-bottom: 1.5rem; }
    .tab-btn { flex: 1; padding: 0.75rem; border: 2px solid #e0e0e0; border-radius: 8px; background: white; font-size: 1rem; font-weight: 500; cursor: pointer; }
    .tab-btn.active { border-color: #1a237e; background: #e8eaf6; color: #1a237e; }
    .form-card { background: white; border-radius: 16px; padding: 2rem; box-shadow: 0 4px 16px rgba(0,0,0,0.08); }
    .form-group { margin-bottom: 1.5rem; }
    label { display: block; margin-bottom: 0.5rem; font-weight: 500; }
    input, select { width: 100%; padding: 0.75rem 1rem; border: 2px solid #e0e0e0; border-radius: 8px; font-size: 1rem; box-sizing: border-box; }
    .search-inline { display: flex; gap: 0.5rem; }
    .search-inline input { flex: 1; }
    .search-inline button { padding: 0.75rem 1rem; background: #1a237e; color: white; border: none; border-radius: 8px; cursor: pointer; }
    .client-info { display: flex; justify-content: space-between; padding: 0.75rem 1rem; background: #e8f5e9; border-radius: 8px; margin-bottom: 1.5rem; font-size: 0.9rem; color: #2e7d32; }
    .btn-action { width: 100%; padding: 0.85rem; color: white; border: none; border-radius: 8px; font-size: 1.05rem; font-weight: 600; cursor: pointer; }
    .btn-action.deposit { background: linear-gradient(135deg, #4caf50, #66bb6a); }
    .btn-action.withdraw { background: linear-gradient(135deg, #f44336, #ef5350); }
    .btn-action:disabled { opacity: 0.5; cursor: not-allowed; }
  `]
})
export class DepositWithdrawComponent {
  private fb = inject(FormBuilder);
  private walletApi = inject(WalletApiService);
  private notification = inject(NotificationService);
  activeTab: 'deposit' | 'withdraw' = 'deposit';
  depositClient: any = null; withdrawClient: any = null; loadingDeposit = false; loadingWithdraw = false;

  depositForm = this.fb.group({
    phone: ['', [Validators.required, phoneValidator()]],
    amount: [null as number | null, [Validators.required, Validators.min(1)]],
    paymentMethod: ['CREDIT_CARD', Validators.required],
    description: ['']
  });

  withdrawForm = this.fb.group({
    phone: ['', [Validators.required, phoneValidator()]],
    amount: [null as number | null, [Validators.required, Validators.min(1)]],
    description: ['']
  });

  searchForDeposit(): void {
    this.walletApi.searchByPhone(this.depositForm.value.phone!).subscribe({
      next: (w) => { this.depositClient = w; },
      error: () => { this.depositClient = null; this.notification.error('Client non trouvé'); }
    });
  }

  searchForWithdraw(): void {
    this.walletApi.searchByPhone(this.withdrawForm.value.phone!).subscribe({
      next: (w) => { this.withdrawClient = w; },
      error: () => { this.withdrawClient = null; this.notification.error('Client non trouvé'); }
    });
  }

  onDeposit(): void {
    if (this.depositForm.invalid || !this.depositClient) return;
    this.loadingDeposit = true;
    const { amount, paymentMethod, description } = this.depositForm.value;
    this.walletApi.deposit(this.depositClient.id, {
      amount: amount!,
      paymentMethod: paymentMethod!,
      description: description || undefined
    }).subscribe({
      next: () => { this.notification.success(`Dépôt de ${amount} XOF effectué !`); this.depositForm.reset({ paymentMethod: 'CREDIT_CARD' }); this.depositClient = null; this.loadingDeposit = false; },
      error: () => { this.loadingDeposit = false; }
    });
  }

  onWithdraw(): void {
    if (this.withdrawForm.invalid || !this.withdrawClient) return;
    this.loadingWithdraw = true;
    const { phone, amount } = this.withdrawForm.value;
    const dto = {
      phoneNumber: phone!,
      amount: amount!
    };
    console.log('📤 Envoi retrait:', JSON.stringify(dto));
    this.walletApi.withdraw(dto).subscribe({
      next: () => {
        this.notification.success(`Retrait de ${amount} XOF effectué !`);
        this.withdrawForm.reset();
        this.withdrawClient = null;
        this.loadingWithdraw = false;
      },
      error: () => { this.loadingWithdraw = false; }
    });
  }
}