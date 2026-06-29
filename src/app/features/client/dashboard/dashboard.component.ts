import { Component, inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { AuthService } from '../../../core/services/auth.service';
import { BalanceStore } from '../../../core/services/balance.store';
import { WalletApiService, Transaction } from '../../../core/services/wallet-api.service';
import { XofPipe } from '../../../shared/pipes/xof.pipe';
import { LoaderComponent } from '../../../shared/components/loader/loader.component';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, RouterLink, XofPipe, LoaderComponent],
  template: `
    <div class="dashboard">
      <h2>Tableau de bord</h2>
      <div class="balance-card">
        <div class="balance-info">
          <span class="balance-label">Solde actuel</span>
          <span class="balance-amount">{{ balanceStore.balance() | xof }}</span>
        </div>
        <div class="balance-icon">💰</div>
      </div>
      <div class="quick-actions">
        <a routerLink="/transfer" class="action-card"><span class="action-icon">💸</span><span class="action-label">Transfert</span></a>
        <a routerLink="/bills/current" class="action-card"><span class="action-icon">📄</span><span class="action-label">Factures</span></a>
        <a routerLink="/transactions" class="action-card"><span class="action-icon">📊</span><span class="action-label">Historique</span></a>
      </div>
      <div class="section">
        <h3>Transactions récentes</h3>
        <app-loader [loading]="loadingTransactions"></app-loader>
        <div class="transactions-list" *ngIf="!loadingTransactions">
          <div *ngIf="recentTransactions.length === 0" class="empty-state">Aucune transaction récente</div>
          <div *ngFor="let tx of recentTransactions" class="transaction-item">
            <div class="tx-left">
              <span class="tx-type-icon">{{ getTransactionIcon(tx.type) }}</span>
              <div class="tx-details"><span class="tx-type">{{ tx.type }}</span><span class="tx-date">{{ tx.createdAt | date:'dd/MM/yyyy HH:mm' }}</span></div>
            </div>
            <span class="tx-amount" [class.positive]="isPositive(tx)" [class.negative]="!isPositive(tx)">{{ isPositive(tx) ? '+' : '-' }}{{ tx.amount | xof }}</span>
          </div>
        </div>
      </div>
      <div class="section">
        <h3>Aperçu mensuel</h3>
        <div class="chart-container">
          <div class="chart-bar"><div class="bar-label">Revenus</div><div class="bar-track"><div class="bar-fill revenue" [style.width.%]="revenuePercent"></div></div><div class="bar-value">{{ totalRevenue | xof }}</div></div>
          <div class="chart-bar"><div class="bar-label">Dépenses</div><div class="bar-track"><div class="bar-fill expense" [style.width.%]="expensePercent"></div></div><div class="bar-value">{{ totalExpense | xof }}</div></div>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .dashboard { max-width: 800px; margin: 0 auto; }
    h2 { color: #1a237e; margin-bottom: 1.5rem; }
    .balance-card { display: flex; align-items: center; justify-content: space-between; background: linear-gradient(135deg, #1a237e, #3949ab); color: white; padding: 2rem; border-radius: 16px; margin-bottom: 2rem; box-shadow: 0 8px 24px rgba(26,35,126,0.3); }
    .balance-label { display: block; font-size: 0.9rem; opacity: 0.8; margin-bottom: 0.5rem; }
    .balance-amount { font-size: 2.2rem; font-weight: 700; }
    .balance-icon { font-size: 3rem; }
    .quick-actions { display: grid; grid-template-columns: repeat(3, 1fr); gap: 1rem; margin-bottom: 2rem; }
    .action-card { display: flex; flex-direction: column; align-items: center; padding: 1.5rem; background: white; border-radius: 12px; text-decoration: none; color: #333; box-shadow: 0 2px 8px rgba(0,0,0,0.08); transition: transform 0.2s; }
    .action-card:hover { transform: translateY(-2px); }
    .action-icon { font-size: 2rem; margin-bottom: 0.5rem; }
    .action-label { font-weight: 500; }
    .section { background: white; border-radius: 12px; padding: 1.5rem; margin-bottom: 1.5rem; box-shadow: 0 2px 8px rgba(0,0,0,0.08); }
    h3 { color: #333; margin-bottom: 1rem; }
    .transactions-list { display: flex; flex-direction: column; gap: 0.75rem; }
    .transaction-item { display: flex; align-items: center; justify-content: space-between; padding: 0.75rem; border-radius: 8px; background: #f8f9fa; }
    .tx-left { display: flex; align-items: center; gap: 0.75rem; }
    .tx-type-icon { font-size: 1.5rem; }
    .tx-details { display: flex; flex-direction: column; }
    .tx-type { font-weight: 500; font-size: 0.9rem; }
    .tx-date { font-size: 0.8rem; color: #666; }
    .tx-amount { font-weight: 600; }
    .tx-amount.positive { color: #4caf50; }
    .tx-amount.negative { color: #f44336; }
    .empty-state { text-align: center; color: #999; padding: 1rem; }
    .chart-container { display: flex; flex-direction: column; gap: 1rem; }
    .chart-bar { display: flex; align-items: center; gap: 1rem; }
    .bar-label { width: 80px; font-size: 0.85rem; color: #666; }
    .bar-track { flex: 1; height: 24px; background: #f0f0f0; border-radius: 12px; overflow: hidden; }
    .bar-fill { height: 100%; border-radius: 12px; transition: width 0.5s ease; }
    .bar-fill.revenue { background: linear-gradient(90deg, #4caf50, #66bb6a); }
    .bar-fill.expense { background: linear-gradient(90deg, #f44336, #ef5350); }
    .bar-value { width: 120px; text-align: right; font-size: 0.85rem; font-weight: 500; }
  `]
})
export class DashboardComponent implements OnInit {
  private authService = inject(AuthService);
  private walletApi = inject(WalletApiService);
  balanceStore = inject(BalanceStore);
  recentTransactions: Transaction[] = [];
  loadingTransactions = true;
  totalRevenue = 0; totalExpense = 0; revenuePercent = 0; expensePercent = 0;

  ngOnInit(): void {
    const phone = this.authService.getPhone();
    this.balanceStore.refresh(phone);
    this.walletApi.getTransactions(phone).subscribe({
      next: (transactions) => { this.recentTransactions = transactions.slice(0, 5); this.calculateStats(transactions); this.loadingTransactions = false; },
      error: () => { this.loadingTransactions = false; }
    });
  }

  private calculateStats(transactions: Transaction[]): void {
    this.totalRevenue = transactions.filter(t => this.isPositive(t)).reduce((s, t) => s + t.amount, 0);
    this.totalExpense = transactions.filter(t => !this.isPositive(t)).reduce((s, t) => s + t.amount, 0);
    const max = Math.max(this.totalRevenue, this.totalExpense, 1);
    this.revenuePercent = (this.totalRevenue / max) * 100;
    this.expensePercent = (this.totalExpense / max) * 100;
  }

  isPositive(tx: Transaction): boolean { return tx.type === 'DEPOSIT' || tx.type === 'TRANSFER_RECEIVED'; }
  getTransactionIcon(type: string): string {
    switch (type) { case 'DEPOSIT': return '⬇️'; case 'WITHDRAWAL': return '⬆️'; case 'TRANSFER_SENT': return '➡️'; case 'TRANSFER_RECEIVED': return '⬅️'; case 'PAYMENT': return '💳'; default: return '💱'; }
  }
}
