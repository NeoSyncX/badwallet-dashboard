import { Component, inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { WalletApiService, Wallet, WalletPage } from '../../../core/services/wallet-api.service';
import { XofPipe } from '../../../shared/pipes/xof.pipe';
import { PhoneFormatPipe } from '../../../shared/pipes/phone-format.pipe';
import { LoaderComponent } from '../../../shared/components/loader/loader.component';

@Component({
  selector: 'app-wallet-list',
  standalone: true,
  imports: [CommonModule, XofPipe, PhoneFormatPipe, LoaderComponent],
  template: `
    <div class="wallet-list-page">
      <h2>🏦 Liste des portefeuilles</h2>
      <app-loader [loading]="loading" message="Chargement..."></app-loader>
      <div *ngIf="!loading">
        <div class="table-container">
          <table>
            <thead><tr><th>ID</th><th>Nom</th><th>Téléphone</th><th>Solde</th><th>Date</th></tr></thead>
            <tbody><tr *ngFor="let w of wallets"><td>{{ w.id }}</td><td>{{ w.firstName }} {{ w.lastName }}</td><td>{{ w.phone | phoneFormat }}</td><td class="balance-cell">{{ w.balance | xof }}</td><td>{{ w.createdAt | date:'dd/MM/yyyy' }}</td></tr></tbody>
          </table>
        </div>
        <div class="pagination" *ngIf="totalPages > 1">
          <button class="page-btn" [disabled]="currentPage === 0" (click)="goToPage(currentPage - 1)">← Précédent</button>
          <span class="page-info">Page {{ currentPage + 1 }} / {{ totalPages }}</span>
          <button class="page-btn" [disabled]="currentPage >= totalPages - 1" (click)="goToPage(currentPage + 1)">Suivant →</button>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .wallet-list-page { max-width: 900px; margin: 0 auto; }
    h2 { color: #1a237e; margin-bottom: 1.5rem; }
    .table-container { background: white; border-radius: 12px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.08); }
    table { width: 100%; border-collapse: collapse; }
    th { background: #f5f5f5; padding: 0.75rem 1rem; text-align: left; font-size: 0.85rem; color: #666; text-transform: uppercase; }
    td { padding: 0.75rem 1rem; border-bottom: 1px solid #f0f0f0; }
    .balance-cell { font-weight: 600; color: #1a237e; }
    .pagination { display: flex; align-items: center; justify-content: center; gap: 1rem; margin-top: 1.5rem; }
    .page-btn { padding: 0.5rem 1rem; border: 1px solid #ddd; border-radius: 6px; background: white; cursor: pointer; }
    .page-btn:disabled { opacity: 0.5; cursor: not-allowed; }
    .page-info { font-size: 0.9rem; color: #666; }
  `]
})
export class WalletListComponent implements OnInit {
  private walletApi = inject(WalletApiService);
  wallets: Wallet[] = []; loading = true; currentPage = 0; totalPages = 0; pageSize = 10;

  ngOnInit(): void { this.loadWallets(); }

  loadWallets(): void {
    this.loading = true;
    this.walletApi.getWallets(this.currentPage, this.pageSize).subscribe({
      next: (page: WalletPage) => { this.wallets = page.content; this.totalPages = page.totalPages; this.loading = false; },
      error: () => { this.loading = false; }
    });
  }

  goToPage(page: number): void { this.currentPage = page; this.loadWallets(); }
}
