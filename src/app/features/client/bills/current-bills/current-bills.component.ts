import { Component, inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { AuthService } from '../../../../core/services/auth.service';
import { BillingApiService, Facture } from '../../../../core/services/billing-api.service';
import { WalletApiService } from '../../../../core/services/wallet-api.service';
import { BalanceStore } from '../../../../core/services/balance.store';
import { NotificationService } from '../../../../core/services/notification.service';
import { XofPipe } from '../../../../shared/pipes/xof.pipe';

@Component({
  selector: 'app-current-bills',
  standalone: true,
  imports: [CommonModule, FormsModule, XofPipe],
  template: `
    <div class="current-bills">
      <div class="filter-bar">
        <label>Unité :</label>
        <select [(ngModel)]="selectedUnite" (ngModelChange)="loadFactures()">
          <option value="">Toutes</option>
          <option value="ELECTRICITE">⚡ Électricité</option>
          <option value="EAU">💧 Eau</option>
        </select>
      </div>
      <div *ngIf="loading">⏳ Chargement...</div>
      <div *ngIf="!loading && factures.length === 0" class="empty-state">🎉 Aucune facture impayée !</div>
      <div *ngIf="!loading && factures.length > 0">
        <div class="select-all">
          <label><input type="checkbox" [checked]="allSelected" (change)="toggleAll()" /> Tout sélectionner</label>
          <span *ngIf="selectedRefs.size > 0">{{ selectedRefs.size }} facture(s) — Total : {{ getSelectedTotal() | xof }}</span>
        </div>
        <div class="factures-list">
          <div *ngFor="let f of factures" class="facture-item" [class.selected]="selectedRefs.has(f.reference)">
            <input type="checkbox" [checked]="selectedRefs.has(f.reference)" (change)="toggleFacture(f.reference)" />
            <div class="facture-info">
              <span class="facture-provider">{{ f.serviceName }} - {{ f.unite }}</span>
              <span class="facture-ref">Réf: {{ f.reference }}</span>
              <span class="facture-due">Échéance: {{ f.dueDate | date:'dd/MM/yyyy' }}</span>
            </div>
            <span class="facture-amount">{{ f.amount | xof }}</span>
          </div>
        </div>
        <button class="btn-pay" [disabled]="selectedRefs.size === 0 || paying" (click)="paySelected()">
          {{ paying ? 'Paiement...' : '💳 Payer' }}
        </button>
      </div>
    </div>
  `,
  styles: [`
    .filter-bar { display: flex; align-items: center; gap: 0.75rem; margin-bottom: 1.5rem; }
    .filter-bar select { padding: 0.5rem 0.75rem; border: 1px solid #ddd; border-radius: 6px; }
    .select-all { display: flex; align-items: center; justify-content: space-between; padding: 0.75rem 1rem; background: #f5f5f5; border-radius: 8px; margin-bottom: 1rem; }
    .factures-list { display: flex; flex-direction: column; gap: 0.75rem; }
    .facture-item { display: flex; align-items: center; gap: 1rem; padding: 1rem; background: white; border: 2px solid #e0e0e0; border-radius: 10px; }
    .facture-item.selected { border-color: #1a237e; background: #e8eaf6; }
    .facture-info { flex: 1; display: flex; flex-direction: column; gap: 0.25rem; }
    .facture-provider { font-weight: 600; }
    .facture-ref { font-size: 0.85rem; color: #666; }
    .facture-due { font-size: 0.8rem; color: #999; }
    .facture-amount { font-weight: 700; font-size: 1.1rem; color: #1a237e; }
    .btn-pay { width: 100%; margin-top: 1.5rem; padding: 0.85rem; background: #4caf50; color: white; border: none; border-radius: 8px; font-size: 1.05rem; font-weight: 600; cursor: pointer; }
    .btn-pay:disabled { opacity: 0.5; cursor: not-allowed; }
    .empty-state { text-align: center; padding: 2rem; color: #666; }
  `]
})
export class CurrentBillsComponent implements OnInit {
  private authService = inject(AuthService);
  private billingApi = inject(BillingApiService);
  private walletApi = inject(WalletApiService);
  private balanceStore = inject(BalanceStore);
  private notification = inject(NotificationService);

  factures: Facture[] = [];
  selectedUnite = '';
  selectedRefs = new Set<string>();
  loading = true;
  paying = false;

  get allSelected(): boolean {
    return this.factures.length > 0 && this.selectedRefs.size === this.factures.length;
  }

  ngOnInit(): void { this.loadFactures(); }

  loadFactures(): void {
    this.loading = true;
    this.selectedRefs.clear();
    this.billingApi.getCurrentFactures(this.authService.walletCode(), this.selectedUnite || undefined).subscribe({
      next: (data) => { this.factures = data; this.loading = false; },
      error: () => { this.factures = []; this.loading = false; }
    });
  }

  toggleFacture(ref: string): void {
    this.selectedRefs.has(ref) ? this.selectedRefs.delete(ref) : this.selectedRefs.add(ref);
  }

  toggleAll(): void {
    this.allSelected ? this.selectedRefs.clear() : this.factures.forEach(f => this.selectedRefs.add(f.reference));
  }

  getSelectedTotal(): number {
    return this.factures.filter(f => this.selectedRefs.has(f.reference)).reduce((s, f) => s + f.amount, 0);
  }

  paySelected(): void {
    if (this.selectedRefs.size === 0) return;
    this.paying = true;
    const refs = Array.from(this.selectedRefs);
    this.walletApi.payFactures({
      walletPhone: this.authService.phoneNumber(),
      factureIds: refs.map(r => Number(r.split('-').pop()))
    }).subscribe({
      next: (result: any) => {
        this.notification.success(`${this.selectedRefs.size} facture(s) payée(s) !`);
        this.balanceStore.updateBalance(result.newBalance);
        this.paying = false;
        this.loadFactures();
      },
      error: () => { this.notification.error('Erreur lors du paiement'); this.paying = false; }
    });
  }
}