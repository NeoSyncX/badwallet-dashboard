import { Injectable, inject, signal, computed } from '@angular/core';
import { WalletApiService } from './wallet-api.service';

@Injectable({ providedIn: 'root' })
export class BalanceStore {
  private api = inject(WalletApiService);
  
  readonly balance = signal<number>(0);
  readonly isLoading = signal<boolean>(false);
  
  readonly formattedBalance = computed(() => {
    return new Intl.NumberFormat('fr-SN', {
      style: 'currency',
      currency: 'XOF',
      maximumFractionDigits: 0
    }).format(this.balance());
  });

  refresh(phone: string): void {
    if (!phone) return;
    this.isLoading.set(true);
    this.api.getBalance(phone).subscribe({
      next: (res: any) => {
        this.balance.set(res.balance);  // ✅ extrait le champ .balance
        this.isLoading.set(false);
      },
      error: () => {
        this.balance.set(0);
        this.isLoading.set(false);
      }
    });
  }

  updateBalance(newBalance: number): void {
    this.balance.set(newBalance);
  }
  
  reset(): void {
    this.balance.set(0);
  }
}