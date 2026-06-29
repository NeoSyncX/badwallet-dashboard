import { Component, inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { AuthService } from '../../../../core/services/auth.service';
import { BillingApiService, Facture } from '../../../../core/services/billing-api.service';
import { XofPipe } from '../../../../shared/pipes/xof.pipe';

@Component({
  selector: 'app-bills-history',
  standalone: true,
  imports: [CommonModule, XofPipe],
  template: `
    <div class="bills-history">
      <h3>Historique des paiements</h3>
      <div *ngIf="loading">⏳ Chargement...</div>
      <div *ngIf="!loading && factures.length === 0" class="empty-state">Aucun historique de paiement</div>
      <table *ngIf="!loading && factures.length > 0">
        <thead><tr><th>Date</th><th>Service</th><th>Référence</th><th>Montant</th><th>Statut</th></tr></thead>
        <tbody>
          <tr *ngFor="let f of factures">
            <td>{{ f.dueDate | date:'dd/MM/yyyy' }}</td>
            <td>{{ f.serviceName }} - {{ f.unite }}</td>
            <td>{{ f.reference }}</td>
            <td>{{ f.amount | xof }}</td>
            <td><span class="status-paid">✅ Payée</span></td>
          </tr>
        </tbody>
      </table>
    </div>
  `,
  styles: [`
    table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; }
    th { background: #f5f5f5; padding: 0.75rem 1rem; text-align: left; font-size: 0.85rem; color: #666; }
    td { padding: 0.75rem 1rem; border-bottom: 1px solid #f0f0f0; }
    .status-paid { color: #4caf50; font-weight: 500; }
    .empty-state { text-align: center; padding: 2rem; color: #999; }
  `]
})
export class BillsHistoryComponent implements OnInit {
  private authService = inject(AuthService);
  private billingApi = inject(BillingApiService);
  factures: Facture[] = [];
  loading = true;

  ngOnInit(): void { this.loadHistory(); }

  loadHistory(): void {
    const now = new Date();
    const debut = new Date(now.getFullYear(), 0, 1).toISOString().split('T')[0];
    const fin = now.toISOString().split('T')[0];
    this.billingApi.getFacturesByPeriod(this.authService.walletCode(), debut, fin).subscribe({
      next: (data) => { this.factures = data.filter(f => f.paid); this.loading = false; },
      error: () => { this.loading = false; }
    });
  }
}