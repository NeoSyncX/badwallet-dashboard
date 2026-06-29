import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { WalletApiService, Wallet } from '../../../core/services/wallet-api.service';
import { NotificationService } from '../../../core/services/notification.service';
import { XofPipe } from '../../../shared/pipes/xof.pipe';
import { PhoneFormatPipe } from '../../../shared/pipes/phone-format.pipe';
import { phoneValidator } from '../../../shared/validators/phone.validator';

@Component({
  selector: 'app-wallet-search',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, XofPipe, PhoneFormatPipe],
  template: `
    <div class="search-page">
      <h2>🔍 Rechercher un client</h2>
      <div class="search-card">
        <form [formGroup]="searchForm" (ngSubmit)="onSearch()">
          <div class="search-bar"><input type="tel" formControlName="phone" placeholder="Numéro de téléphone..." /><button type="submit" [disabled]="searchForm.invalid || loading">{{ loading ? '...' : '🔍' }}</button></div>
          <span class="error-msg" *ngIf="searchForm.get('phone')?.touched && searchForm.get('phone')?.hasError('invalidPhone')">Numéro invalide</span>
        </form>
        <div class="result-card" *ngIf="wallet">
          <h3>Détails du portefeuille</h3>
          <div class="detail-grid">
            <div class="detail-item"><span class="detail-label">ID</span><span class="detail-value">{{ wallet.id }}</span></div>
            <div class="detail-item"><span class="detail-label">Nom</span><span class="detail-value">{{ wallet.firstName }} {{ wallet.lastName }}</span></div>
            <div class="detail-item"><span class="detail-label">Téléphone</span><span class="detail-value">{{ wallet.phone | phoneFormat }}</span></div>
            <div class="detail-item"><span class="detail-label">Solde</span><span class="detail-value balance">{{ wallet.balance | xof }}</span></div>
          </div>
        </div>
        <div class="not-found" *ngIf="notFound">❌ Aucun portefeuille trouvé</div>
      </div>
    </div>
  `,
  styles: [`
    .search-page { max-width: 600px; margin: 0 auto; }
    h2 { color: #1a237e; margin-bottom: 1.5rem; }
    .search-card { background: white; border-radius: 16px; padding: 2rem; box-shadow: 0 4px 16px rgba(0,0,0,0.08); }
    .search-bar { display: flex; gap: 0.5rem; }
    .search-bar input { flex: 1; padding: 0.75rem 1rem; border: 2px solid #e0e0e0; border-radius: 8px; font-size: 1rem; }
    .search-bar input:focus { outline: none; border-color: #1a237e; }
    .search-bar button { padding: 0.75rem 1.25rem; background: #1a237e; color: white; border: none; border-radius: 8px; font-size: 1.2rem; cursor: pointer; }
    .search-bar button:disabled { opacity: 0.5; }
    .error-msg { color: #f44336; font-size: 0.8rem; margin-top: 0.25rem; display: block; }
    .result-card { margin-top: 1.5rem; padding: 1.5rem; background: #f8f9fa; border-radius: 12px; }
    .result-card h3 { color: #1a237e; margin-bottom: 1rem; }
    .detail-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; }
    .detail-item { display: flex; flex-direction: column; }
    .detail-label { font-size: 0.8rem; color: #666; margin-bottom: 0.25rem; }
    .detail-value { font-weight: 500; }
    .detail-value.balance { color: #1a237e; font-size: 1.2rem; font-weight: 700; }
    .not-found { margin-top: 1.5rem; text-align: center; padding: 1rem; color: #f44336; font-weight: 500; }
  `]
})
export class WalletSearchComponent {
  private fb = inject(FormBuilder);
  private walletApi = inject(WalletApiService);
  private notification = inject(NotificationService);
  loading = false; wallet: Wallet | null = null; notFound = false;

  searchForm = this.fb.group({ phone: ['', [Validators.required, phoneValidator()]] });

  onSearch(): void {
    if (this.searchForm.invalid) return;
    this.loading = true; this.wallet = null; this.notFound = false;
    this.walletApi.searchByPhone(this.searchForm.value.phone!).subscribe({
      next: (wallet) => { this.wallet = wallet; this.loading = false; },
      error: () => { this.notFound = true; this.loading = false; }
    });
  }
}
