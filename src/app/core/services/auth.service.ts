import { Injectable, signal, computed, inject } from '@angular/core';
import { Router } from '@angular/router';

export interface User {
  phone: string;
  walletCode: string;
  role: 'CLIENT' | 'AGENT';
  walletId?: number;
}

@Injectable({ providedIn: 'root' })
export class AuthService {
  private router = inject(Router);
  
  private readonly _user = signal<User | null>(null);
  
  readonly user = this._user.asReadonly();
  readonly isLoggedIn = computed(() => this._user() !== null);
  readonly isClient = computed(() => this._user()?.role === 'CLIENT');
  readonly isAgent = computed(() => this._user()?.role === 'AGENT');
  readonly phoneNumber = computed(() => this._user()?.phone ?? '');
  readonly walletCode = computed(() => this._user()?.walletCode ?? '');

  constructor() {
    const stored = localStorage.getItem('badwallet_user');
    if (stored) {
      try { this._user.set(JSON.parse(stored)); }
      catch { localStorage.removeItem('badwallet_user'); }
    }
  }

  login(phone: string, role: 'CLIENT' | 'AGENT', walletCode?: string, walletId?: number): void {
    const user: User = { phone, walletCode: walletCode ?? '', role, walletId };
    this._user.set(user);
    localStorage.setItem('badwallet_user', JSON.stringify(user));
    this.router.navigate([role === 'CLIENT' ? '/dashboard' : '/admin/wallets']);
  }

  logout(): void {
    this._user.set(null);
    localStorage.removeItem('badwallet_user');
    this.router.navigate(['/login']);
  }

  getPhone(): string { return this._user()?.phone ?? ''; }
  getWalletId(): number | undefined { return this._user()?.walletId; }
}