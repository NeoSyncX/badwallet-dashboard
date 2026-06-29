import { Component, inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { AuthService } from '../../../core/services/auth.service';
import { WalletApiService, Transaction } from '../../../core/services/wallet-api.service';
import { XofPipe } from '../../../shared/pipes/xof.pipe';
import { PhoneFormatPipe } from '../../../shared/pipes/phone-format.pipe';
import { LoaderComponent } from '../../../shared/components/loader/loader.component';

@Component({
  selector: 'app-transactions',
  standalone: true,
  imports: [CommonModule, FormsModule, XofPipe, PhoneFormatPipe, LoaderComponent],
  template: `
    <div class="transactions-page">
      <h2>📊 Historique des transactions</h2>
      <div class="filters">
        <div class="filter-group"><label>Type</label><select [(ngModel)]="filterType" (ngModelChange)="applyFilters()"><option value="">Tous</option><option value="DEPOSIT">Dépôts</option><option value="WITHDRAWAL">Retraits</option><option value="TRANSFER_SENT">Envoyés</option><option value="TRANSFER_RECEIVED">Reçus</option><option value="PAYMENT">Paiements</option></select></div>
        <div class="filter-group"><label>Date début</label><input type="date" [(ngModel)]="filterDateStart" (ngModelChange)="applyFilters()" /></div>
        <div class="filter-group"><label>Date fin</label><input type="date" [(ngModel)]="filterDateEnd" (ngModelChange)="applyFilters()" /></div>
      </div>
      <app-loader [loading]="loading" message="Chargement..."></app-loader>
      <div class="table-container" *ngIf="!loading">
        <div *ngIf="filteredTransactions.length === 0" class="empty-state">Aucune transaction trouvée</div>
        <table *ngIf="filteredTransactions.length > 0">
          <thead><tr><th>Date</th><th>Type</th><th>Détails</th><th>Montant</th><th>Statut</th></tr></thead>
          <tbody>
            <tr *ngFor="let tx of filteredTransactions">
              <td>{{ tx.createdAt | date:'dd/MM/yyyy HH:mm' }}</td>
              <td><span class="type-badge" [class]="'type-' + (tx.type || '').toLowerCase()">{{ getTypeLabel(tx.type) }}</span></td>
              <td><span *ngIf="tx.description">{{ tx.description }}</span><span *ngIf="tx.receiverPhone" class="phone-detail">→ {{ tx.receiverPhone | phoneFormat }}</span><span *ngIf="tx.senderPhone && tx.type === 'TRANSFER_RECEIVED'" class="phone-detail">← {{ tx.senderPhone | phoneFormat }}</span></td>
              <td [class.positive]="isPositive(tx)" [class.negative]="!isPositive(tx)">{{ isPositive(tx) ? '+' : '-' }}{{ tx.amount | xof }}</td>
              <td><span class="status-badge" [class]="'status-' + (tx.status || '').toLowerCase()">{{ tx.status }}</span></td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  `,
  styles: [`
    .transactions-page { max-width: 900px; margin: 0 auto; }
    h2 { color: #1a237e; margin-bottom: 1.5rem; }
    .filters { display: flex; gap: 1rem; margin-bottom: 1.5rem; flex-wrap: wrap; }
    .filter-group { display: flex; flex-direction: column; gap: 0.25rem; }
    .filter-group label { font-size: 0.8rem; color: #666; }
    .filter-group select, .filter-group input { padding: 0.5rem 0.75rem; border: 1px solid #ddd; border-radius: 6px; font-size: 0.9rem; }
    .table-container { background: white; border-radius: 12px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.08); }
    table { width: 100%; border-collapse: collapse; }
    th { background: #f5f5f5; padding: 0.75rem 1rem; text-align: left; font-size: 0.85rem; color: #666; text-transform: uppercase; }
    td { padding: 0.75rem 1rem; border-bottom: 1px solid #f0f0f0; }
    .positive { color: #4caf50; font-weight: 600; }
    .negative { color: #f44336; font-weight: 600; }
    .type-badge { padding: 0.25rem 0.5rem; border-radius: 4px; font-size: 0.8rem; font-weight: 500; }
    .type-deposit { background: #e8f5e9; color: #2e7d32; }
    .type-withdrawal { background: #ffebee; color: #c62828; }
    .type-transfer_sent { background: #fff3e0; color: #e65100; }
    .type-transfer_received { background: #e3f2fd; color: #1565c0; }
    .type-payment { background: #f3e5f5; color: #6a1b9a; }
    .status-badge { padding: 0.2rem 0.5rem; border-radius: 4px; font-size: 0.75rem; }
    .status-completed, .status-success { background: #e8f5e9; color: #2e7d32; }
    .status-pending { background: #fff3e0; color: #e65100; }
    .status-failed { background: #ffebee; color: #c62828; }
    .phone-detail { font-size: 0.85rem; color: #666; }
    .empty-state { text-align: center; padding: 2rem; color: #999; }
  `]
})
export class TransactionsComponent implements OnInit {
  private authService = inject(AuthService);
  private walletApi = inject(WalletApiService);
  transactions: Transaction[] = []; filteredTransactions: Transaction[] = []; loading = true;
  filterType = ''; filterDateStart = ''; filterDateEnd = '';

  ngOnInit(): void {
    this.walletApi.getTransactions(this.authService.getPhone()).subscribe({
      next: (data) => { this.transactions = data; this.filteredTransactions = data; this.loading = false; },
      error: () => { this.loading = false; }
    });
  }

  applyFilters(): void {
    this.filteredTransactions = this.transactions.filter(tx => {
      if (this.filterType && tx.type !== this.filterType) return false;
      if (this.filterDateStart && new Date(tx.createdAt) < new Date(this.filterDateStart)) return false;
      if (this.filterDateEnd) { const end = new Date(this.filterDateEnd); end.setHours(23,59,59); if (new Date(tx.createdAt) > end) return false; }
      return true;
    });
  }

  isPositive(tx: Transaction): boolean { return tx.type === 'DEPOSIT' || tx.type === 'TRANSFER_RECEIVED'; }
  getTypeLabel(type: string): string {
    switch (type) { case 'DEPOSIT': return 'Dépôt'; case 'WITHDRAWAL': return 'Retrait'; case 'TRANSFER_SENT': return 'Envoyé'; case 'TRANSFER_RECEIVED': return 'Reçu'; case 'PAYMENT': return 'Paiement'; default: return type; }
  }
}
