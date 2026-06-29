import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterOutlet, RouterLink, RouterLinkActive } from '@angular/router';
import { AuthService } from './core/services/auth.service';
import { BalanceStore } from './core/services/balance.store';
import { XofPipe } from './shared/pipes/xof.pipe';
import { ToastComponent } from './shared/components/toast/toast.component';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [CommonModule, RouterOutlet, RouterLink, RouterLinkActive, XofPipe, ToastComponent],
  template: `
    <div class="app-container">
      <header class="header" *ngIf="authService.isLoggedIn()">
        <div class="header-left">
          <h1 class="logo">💰 BadWallet</h1>
        </div>
        <div class="header-center">
          <nav class="nav-links" *ngIf="authService.isClient()">
            <a routerLink="/dashboard" routerLinkActive="active">Dashboard</a>
            <a routerLink="/transfer" routerLinkActive="active">Transfert</a>
            <a routerLink="/bills" routerLinkActive="active">Factures</a>
            <a routerLink="/transactions" routerLinkActive="active">Historique</a>
          </nav>
          <nav class="nav-links" *ngIf="authService.isAgent()">
            <a routerLink="/admin/wallets" routerLinkActive="active">Portefeuilles</a>
            <a routerLink="/admin/wallets/create" routerLinkActive="active">Créer</a>
            <a routerLink="/admin/wallets/search" routerLinkActive="active">Rechercher</a>
            <a routerLink="/admin/wallets/deposit-withdraw" routerLinkActive="active">Dépôt/Retrait</a>
          </nav>
        </div>
        <div class="header-right">
          <span class="balance-badge" *ngIf="authService.isClient()">
            {{ balanceStore.balance() | xof }}
          </span>
          <span class="user-info">{{ authService.user()?.phone }}</span>
          <button class="btn-logout" (click)="logout()">Déconnexion</button>
        </div>
      </header>
      <main class="main-content">
        <router-outlet></router-outlet>
      </main>
      <app-toast></app-toast>
    </div>
  `,
  styles: [`
    .app-container { min-height: 100vh; background: #f5f7fa; }
    .header { display: flex; align-items: center; justify-content: space-between; padding: 0.75rem 2rem; background: linear-gradient(135deg, #1a237e, #283593); color: white; box-shadow: 0 2px 8px rgba(0,0,0,0.15); }
    .logo { font-size: 1.4rem; margin: 0; }
    .nav-links a { color: rgba(255,255,255,0.8); text-decoration: none; margin: 0 0.75rem; padding: 0.5rem 0.75rem; border-radius: 6px; transition: all 0.2s; }
    .nav-links a:hover, .nav-links a.active { color: white; background: rgba(255,255,255,0.15); }
    .header-right { display: flex; align-items: center; gap: 1rem; }
    .balance-badge { background: #4caf50; padding: 0.4rem 0.8rem; border-radius: 20px; font-weight: 600; font-size: 0.9rem; }
    .user-info { font-size: 0.85rem; opacity: 0.9; }
    .btn-logout { background: rgba(255,255,255,0.15); border: 1px solid rgba(255,255,255,0.3); color: white; padding: 0.4rem 0.8rem; border-radius: 6px; cursor: pointer; transition: all 0.2s; }
    .btn-logout:hover { background: rgba(255,255,255,0.25); }
    .main-content { padding: 2rem; max-width: 1200px; margin: 0 auto; }
  `]
})
export class AppComponent {
  authService = inject(AuthService);
  balanceStore = inject(BalanceStore);
  logout() { this.authService.logout(); }
}
