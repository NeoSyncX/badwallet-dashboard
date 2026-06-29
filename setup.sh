#!/bin/bash
# BadWallet Angular - Script d'installation automatique
# Usage: Après "ng new badwallet --standalone --routing --style=scss && cd badwallet"
# Copiez ce script dans le dossier badwallet et lancez: bash setup.sh

echo "🚀 Génération du projet BadWallet Angular..."

# ===== environments =====
mkdir -p src/environments

cat > src/environments/environment.ts << 'ENDOFFILE'
export const environment = {
  production: false,
  apiBaseUrl: 'http://localhost:8080/api'
};
ENDOFFILE

cat > src/environments/environment.prod.ts << 'ENDOFFILE'
export const environment = {
  production: true,
  apiBaseUrl: 'http://localhost:8080/api'
};
ENDOFFILE

# ===== app config =====
cat > src/app/app.config.ts << 'ENDOFFILE'
import { ApplicationConfig, provideZoneChangeDetection } from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { routes } from './app.routes';
import { errorInterceptor } from './core/interceptors/error.interceptor';

export const appConfig: ApplicationConfig = {
  providers: [
    provideZoneChangeDetection({ eventCoalescing: true }),
    provideRouter(routes),
    provideHttpClient(withInterceptors([errorInterceptor]))
  ]
};
ENDOFFILE

# ===== app routes =====
cat > src/app/app.routes.ts << 'ENDOFFILE'
import { Routes } from '@angular/router';
import { clientGuard } from './core/guards/client.guard';
import { agentGuard } from './core/guards/agent.guard';

export const routes: Routes = [
  { path: '', redirectTo: '/dashboard', pathMatch: 'full' },
  {
    path: 'dashboard',
    loadComponent: () => import('./features/client/dashboard/dashboard.component').then(m => m.DashboardComponent),
    canActivate: [clientGuard]
  },
  {
    path: 'transactions',
    loadComponent: () => import('./features/client/transactions/transactions.component').then(m => m.TransactionsComponent),
    canActivate: [clientGuard]
  },
  {
    path: 'transfer',
    loadComponent: () => import('./features/client/transfer/transfer.component').then(m => m.TransferComponent),
    canActivate: [clientGuard]
  },
  {
    path: 'bills',
    loadComponent: () => import('./features/client/bills/bills.component').then(m => m.BillsComponent),
    canActivate: [clientGuard],
    children: [
      { path: '', redirectTo: 'current', pathMatch: 'full' },
      {
        path: 'current',
        loadComponent: () => import('./features/client/bills/current-bills/current-bills.component').then(m => m.CurrentBillsComponent)
      },
      {
        path: 'history',
        loadComponent: () => import('./features/client/bills/bills-history/bills-history.component').then(m => m.BillsHistoryComponent)
      }
    ]
  },
  {
    path: 'admin/wallets',
    loadComponent: () => import('./features/agent/wallet-list/wallet-list.component').then(m => m.WalletListComponent),
    canActivate: [agentGuard]
  },
  {
    path: 'admin/wallets/create',
    loadComponent: () => import('./features/agent/wallet-create/wallet-create.component').then(m => m.WalletCreateComponent),
    canActivate: [agentGuard]
  },
  {
    path: 'admin/wallets/search',
    loadComponent: () => import('./features/agent/wallet-search/wallet-search.component').then(m => m.WalletSearchComponent),
    canActivate: [agentGuard]
  },
  {
    path: 'admin/wallets/deposit-withdraw',
    loadComponent: () => import('./features/agent/deposit-withdraw/deposit-withdraw.component').then(m => m.DepositWithdrawComponent),
    canActivate: [agentGuard]
  },
  {
    path: 'login',
    loadComponent: () => import('./features/login/login.component').then(m => m.LoginComponent)
  },
  { path: '**', redirectTo: '/dashboard' }
];
ENDOFFILE

# ===== app component =====
cat > src/app/app.component.ts << 'ENDOFFILE'
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
          <span class="user-info">{{ authService.currentUser()?.phone }}</span>
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
ENDOFFILE

# ===== core services =====
mkdir -p src/app/core/services src/app/core/guards src/app/core/interceptors

cat > src/app/core/services/auth.service.ts << 'ENDOFFILE'
import { Injectable, signal, computed } from '@angular/core';
import { Router } from '@angular/router';

export interface User {
  phone: string;
  role: 'CLIENT' | 'AGENT';
  walletId?: number;
}

@Injectable({ providedIn: 'root' })
export class AuthService {
  private user = signal<User | null>(null);
  currentUser = this.user.asReadonly();
  isLoggedIn = computed(() => this.user() !== null);
  isClient = computed(() => this.user()?.role === 'CLIENT');
  isAgent = computed(() => this.user()?.role === 'AGENT');

  constructor(private router: Router) {
    const stored = localStorage.getItem('badwallet_user');
    if (stored) this.user.set(JSON.parse(stored));
  }

  login(phone: string, role: 'CLIENT' | 'AGENT', walletId?: number): void {
    const user: User = { phone, role, walletId };
    this.user.set(user);
    localStorage.setItem('badwallet_user', JSON.stringify(user));
    this.router.navigate([role === 'CLIENT' ? '/dashboard' : '/admin/wallets']);
  }

  logout(): void {
    this.user.set(null);
    localStorage.removeItem('badwallet_user');
    this.router.navigate(['/login']);
  }

  getPhone(): string { return this.user()?.phone ?? ''; }
  getWalletId(): number | undefined { return this.user()?.walletId; }
}
ENDOFFILE

cat > src/app/core/services/wallet-api.service.ts << 'ENDOFFILE'
import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';

export interface Wallet { id: number; phone: string; firstName: string; lastName: string; balance: number; createdAt?: string; }
export interface WalletPage { content: Wallet[]; totalElements: number; totalPages: number; number: number; size: number; }
export interface CreateWalletDto { phone: string; firstName: string; lastName: string; pin?: string; }
export interface TransferDto { senderPhone: string; receiverPhone: string; amount: number; description?: string; }
export interface DepositDto { amount: number; description?: string; }
export interface WithdrawDto { walletId: number; phone: string; amount: number; description?: string; }
export interface Transaction { id: number; type: string; amount: number; description?: string; senderPhone?: string; receiverPhone?: string; createdAt: string; status: string; }

@Injectable({ providedIn: 'root' })
export class WalletApiService {
  private readonly BASE = `${environment.apiBaseUrl}/wallets`;
  private http = inject(HttpClient);

  getWallets(page: number = 0, size: number = 10): Observable<WalletPage> {
    return this.http.get<WalletPage>(this.BASE, { params: new HttpParams().set('page', page).set('size', size) });
  }
  createWallet(dto: CreateWalletDto): Observable<Wallet> { return this.http.post<Wallet>(this.BASE, dto); }
  searchByPhone(phone: string): Observable<Wallet> { return this.http.get<Wallet>(`${this.BASE}/${phone}`); }
  deposit(walletId: number, dto: DepositDto): Observable<any> { return this.http.post(`${this.BASE}/${walletId}/deposit`, dto); }
  withdraw(dto: WithdrawDto): Observable<any> { return this.http.post(`${this.BASE}/withdraw`, dto); }
  getBalance(phone: string): Observable<number> { return this.http.get<number>(`${this.BASE}/${phone}/balance`); }
  transfer(dto: TransferDto): Observable<any> { return this.http.post(`${this.BASE}/transfer`, dto); }
  getTransactions(phone: string): Observable<Transaction[]> { return this.http.get<Transaction[]>(`${this.BASE}/${phone}/transactions`); }
  payFactures(payload: { walletPhone: string; factureIds: number[] }): Observable<any> { return this.http.post(`${this.BASE}/pay-factures`, payload); }
}
ENDOFFILE

cat > src/app/core/services/billing-api.service.ts << 'ENDOFFILE'
import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';

export interface Facture { id: number; provider: string; reference: string; amount: number; dueDate: string; status: 'UNPAID' | 'PAID'; description?: string; }

@Injectable({ providedIn: 'root' })
export class BillingApiService {
  private readonly BASE = `${environment.apiBaseUrl}/external/factures`;
  private http = inject(HttpClient);

  getUnpaidFactures(phone: string, provider?: string): Observable<Facture[]> {
    let params = new HttpParams().set('phone', phone);
    if (provider) params = params.set('provider', provider);
    return this.http.get<Facture[]>(`${this.BASE}/unpaid`, { params });
  }
  getFactureHistory(phone: string): Observable<Facture[]> {
    return this.http.get<Facture[]>(`${this.BASE}/history`, { params: new HttpParams().set('phone', phone) });
  }
  getProviders(): Observable<string[]> { return this.http.get<string[]>(`${this.BASE}/providers`); }
}
ENDOFFILE

cat > src/app/core/services/balance.store.ts << 'ENDOFFILE'
import { Injectable, inject, signal } from '@angular/core';
import { WalletApiService } from './wallet-api.service';

@Injectable({ providedIn: 'root' })
export class BalanceStore {
  private walletApi = inject(WalletApiService);
  readonly balance = signal<number>(0);
  readonly loading = signal<boolean>(false);

  refresh(phone: string): void {
    if (!phone) return;
    this.loading.set(true);
    this.walletApi.getBalance(phone).subscribe({
      next: (b) => { this.balance.set(b); this.loading.set(false); },
      error: () => { this.loading.set(false); }
    });
  }
  reset(): void { this.balance.set(0); }
}
ENDOFFILE

cat > src/app/core/services/notification.service.ts << 'ENDOFFILE'
import { Injectable, signal } from '@angular/core';

export interface Toast { id: number; message: string; type: 'success' | 'error' | 'info' | 'warning'; }

@Injectable({ providedIn: 'root' })
export class NotificationService {
  private counter = 0;
  readonly toasts = signal<Toast[]>([]);

  success(message: string): void { this.addToast(message, 'success'); }
  error(message: string): void { this.addToast(message, 'error'); }
  info(message: string): void { this.addToast(message, 'info'); }
  warning(message: string): void { this.addToast(message, 'warning'); }

  private addToast(message: string, type: Toast['type']): void {
    const id = ++this.counter;
    this.toasts.update(list => [...list, { id, message, type }]);
    setTimeout(() => this.removeToast(id), 4000);
  }
  removeToast(id: number): void { this.toasts.update(list => list.filter(t => t.id !== id)); }
}
ENDOFFILE

# ===== interceptors =====
cat > src/app/core/interceptors/error.interceptor.ts << 'ENDOFFILE'
import { HttpInterceptorFn, HttpErrorResponse } from '@angular/common/http';
import { inject } from '@angular/core';
import { catchError, throwError } from 'rxjs';
import { NotificationService } from '../services/notification.service';
import { AuthService } from '../services/auth.service';

export const errorInterceptor: HttpInterceptorFn = (req, next) => {
  const notification = inject(NotificationService);
  const auth = inject(AuthService);

  return next(req).pipe(
    catchError((error: HttpErrorResponse) => {
      let message = 'Une erreur est survenue';
      if (error.status === 0) message = 'Impossible de contacter le serveur.';
      else if (error.status === 401) { message = 'Session expirée.'; auth.logout(); }
      else if (error.status === 403) message = 'Accès non autorisé.';
      else if (error.status === 404) message = 'Ressource non trouvée.';
      else if (error.status === 400) message = error.error?.message || 'Requête invalide.';
      else if (error.status >= 500) message = 'Erreur serveur.';
      if (error.error?.message) message = error.error.message;
      notification.error(message);
      return throwError(() => error);
    })
  );
};
ENDOFFILE

# ===== guards =====
cat > src/app/core/guards/client.guard.ts << 'ENDOFFILE'
import { CanActivateFn, Router } from '@angular/router';
import { inject } from '@angular/core';
import { AuthService } from '../services/auth.service';

export const clientGuard: CanActivateFn = () => {
  const auth = inject(AuthService);
  const router = inject(Router);
  if (!auth.isLoggedIn()) { router.navigate(['/login']); return false; }
  if (!auth.isClient()) { router.navigate(['/admin/wallets']); return false; }
  return true;
};
ENDOFFILE

cat > src/app/core/guards/agent.guard.ts << 'ENDOFFILE'
import { CanActivateFn, Router } from '@angular/router';
import { inject } from '@angular/core';
import { AuthService } from '../services/auth.service';

export const agentGuard: CanActivateFn = () => {
  const auth = inject(AuthService);
  const router = inject(Router);
  if (!auth.isLoggedIn()) { router.navigate(['/login']); return false; }
  if (!auth.isAgent()) { router.navigate(['/dashboard']); return false; }
  return true;
};
ENDOFFILE

# ===== shared =====
mkdir -p src/app/shared/pipes src/app/shared/validators src/app/shared/components/toast src/app/shared/components/loader

cat > src/app/shared/pipes/xof.pipe.ts << 'ENDOFFILE'
import { Pipe, PipeTransform } from '@angular/core';

@Pipe({ name: 'xof', standalone: true })
export class XofPipe implements PipeTransform {
  transform(value: number | null | undefined): string {
    if (value === null || value === undefined) return '0 XOF';
    return new Intl.NumberFormat('fr-SN', { style: 'currency', currency: 'XOF', maximumFractionDigits: 0 }).format(value);
  }
}
ENDOFFILE

cat > src/app/shared/pipes/phone-format.pipe.ts << 'ENDOFFILE'
import { Pipe, PipeTransform } from '@angular/core';

@Pipe({ name: 'phoneFormat', standalone: true })
export class PhoneFormatPipe implements PipeTransform {
  transform(value: string | null | undefined): string {
    if (!value) return '';
    const cleaned = value.replace(/\D/g, '');
    if (cleaned.length === 12 && cleaned.startsWith('221')) {
      return `+${cleaned.substring(0,3)} ${cleaned.substring(3,5)} ${cleaned.substring(5,8)} ${cleaned.substring(8,10)} ${cleaned.substring(10,12)}`;
    }
    if (cleaned.length === 9) {
      return `${cleaned.substring(0,2)} ${cleaned.substring(2,5)} ${cleaned.substring(5,7)} ${cleaned.substring(7,9)}`;
    }
    return value;
  }
}
ENDOFFILE

cat > src/app/shared/validators/phone.validator.ts << 'ENDOFFILE'
import { AbstractControl, ValidationErrors, ValidatorFn } from '@angular/forms';

export function phoneValidator(): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    if (!control.value) return null;
    const cleaned = control.value.replace(/[\s\-\+]/g, '');
    const withCountryCode = /^221[7-8][0-9]{8}$/.test(cleaned);
    const localFormat = /^[7-8][0-9]{8}$/.test(cleaned);
    return (withCountryCode || localFormat) ? null : { invalidPhone: { value: control.value } };
  };
}

export function differentPhoneValidator(currentPhone: string): ValidatorFn {
  return (group: AbstractControl): ValidationErrors | null => {
    const destination = group.get('destination')?.value;
    if (!destination || !currentPhone) return null;
    const normDest = destination.replace(/[\s\-\+]/g, '').replace(/^221/, '');
    const normCurrent = currentPhone.replace(/[\s\-\+]/g, '').replace(/^221/, '');
    return normDest === normCurrent ? { samePhone: true } : null;
  };
}
ENDOFFILE

cat > src/app/shared/components/toast/toast.component.ts << 'ENDOFFILE'
import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { NotificationService, Toast } from '../../../core/services/notification.service';

@Component({
  selector: 'app-toast',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="toast-container">
      @for (toast of notificationService.toasts(); track toast.id) {
        <div class="toast" [class]="'toast-' + toast.type" (click)="dismiss(toast)">
          <span class="toast-icon">
            @switch (toast.type) { @case ('success') { ✅ } @case ('error') { ❌ } @case ('warning') { ⚠️ } @case ('info') { ℹ️ } }
          </span>
          <span class="toast-message">{{ toast.message }}</span>
          <button class="toast-close" (click)="dismiss(toast)">×</button>
        </div>
      }
    </div>
  `,
  styles: [`
    .toast-container { position: fixed; top: 1rem; right: 1rem; z-index: 9999; display: flex; flex-direction: column; gap: 0.5rem; max-width: 400px; }
    .toast { display: flex; align-items: center; gap: 0.5rem; padding: 0.75rem 1rem; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.15); animation: slideIn 0.3s ease; cursor: pointer; }
    .toast-success { background: #e8f5e9; border-left: 4px solid #4caf50; color: #2e7d32; }
    .toast-error { background: #ffebee; border-left: 4px solid #f44336; color: #c62828; }
    .toast-warning { background: #fff3e0; border-left: 4px solid #ff9800; color: #e65100; }
    .toast-info { background: #e3f2fd; border-left: 4px solid #2196f3; color: #1565c0; }
    .toast-message { flex: 1; font-size: 0.9rem; }
    .toast-close { background: none; border: none; font-size: 1.2rem; cursor: pointer; opacity: 0.6; }
    .toast-close:hover { opacity: 1; }
    @keyframes slideIn { from { transform: translateX(100%); opacity: 0; } to { transform: translateX(0); opacity: 1; } }
  `]
})
export class ToastComponent {
  notificationService = inject(NotificationService);
  dismiss(toast: Toast): void { this.notificationService.removeToast(toast.id); }
}
ENDOFFILE

cat > src/app/shared/components/loader/loader.component.ts << 'ENDOFFILE'
import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-loader',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="loader-overlay" *ngIf="loading">
      <div class="spinner"></div>
      <p *ngIf="message">{{ message }}</p>
    </div>
  `,
  styles: [`
    .loader-overlay { display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 2rem; }
    .spinner { width: 40px; height: 40px; border: 4px solid #e0e0e0; border-top: 4px solid #1a237e; border-radius: 50%; animation: spin 0.8s linear infinite; }
    p { margin-top: 1rem; color: #666; font-size: 0.9rem; }
    @keyframes spin { to { transform: rotate(360deg); } }
  `]
})
export class LoaderComponent {
  @Input() loading = false;
  @Input() message = '';
}
ENDOFFILE

# ===== features =====
mkdir -p src/app/features/login
mkdir -p src/app/features/client/dashboard src/app/features/client/transfer src/app/features/client/transactions src/app/features/client/bills/current-bills src/app/features/client/bills/bills-history
mkdir -p src/app/features/agent/wallet-list src/app/features/agent/wallet-create src/app/features/agent/wallet-search src/app/features/agent/deposit-withdraw

# ===== LOGIN =====
cat > src/app/features/login/login.component.ts << 'ENDOFFILE'
import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { AuthService } from '../../core/services/auth.service';
import { WalletApiService } from '../../core/services/wallet-api.service';
import { NotificationService } from '../../core/services/notification.service';
import { phoneValidator } from '../../shared/validators/phone.validator';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  template: `
    <div class="login-container">
      <div class="login-card">
        <div class="login-header">
          <h1>💰 BadWallet</h1>
          <p>Connectez-vous à votre espace</p>
        </div>
        <form [formGroup]="loginForm" (ngSubmit)="onSubmit()">
          <div class="form-group">
            <label for="phone">Numéro de téléphone</label>
            <input id="phone" type="tel" formControlName="phone" placeholder="77 123 45 67" [class.error]="loginForm.get('phone')?.touched && loginForm.get('phone')?.invalid" />
            <span class="error-msg" *ngIf="loginForm.get('phone')?.touched && loginForm.get('phone')?.hasError('required')">Le numéro est requis</span>
            <span class="error-msg" *ngIf="loginForm.get('phone')?.touched && loginForm.get('phone')?.hasError('invalidPhone')">Numéro invalide</span>
          </div>
          <div class="form-group">
            <label>Type de compte</label>
            <div class="role-selector">
              <button type="button" class="role-btn" [class.active]="loginForm.get('role')?.value === 'CLIENT'" (click)="setRole('CLIENT')">👤 Client</button>
              <button type="button" class="role-btn" [class.active]="loginForm.get('role')?.value === 'AGENT'" (click)="setRole('AGENT')">🏦 Agent</button>
            </div>
          </div>
          <button type="submit" class="btn-submit" [disabled]="loginForm.invalid || loading">{{ loading ? 'Connexion...' : 'Se connecter' }}</button>
        </form>
      </div>
    </div>
  `,
  styles: [`
    .login-container { display: flex; align-items: center; justify-content: center; min-height: 100vh; background: linear-gradient(135deg, #1a237e 0%, #283593 50%, #3949ab 100%); }
    .login-card { background: white; border-radius: 16px; padding: 2.5rem; width: 100%; max-width: 420px; box-shadow: 0 20px 60px rgba(0,0,0,0.3); }
    .login-header { text-align: center; margin-bottom: 2rem; }
    .login-header h1 { font-size: 2rem; color: #1a237e; margin-bottom: 0.5rem; }
    .login-header p { color: #666; }
    .form-group { margin-bottom: 1.5rem; }
    label { display: block; margin-bottom: 0.5rem; font-weight: 500; color: #333; }
    input { width: 100%; padding: 0.75rem 1rem; border: 2px solid #e0e0e0; border-radius: 8px; font-size: 1rem; box-sizing: border-box; }
    input:focus { outline: none; border-color: #1a237e; }
    input.error { border-color: #f44336; }
    .error-msg { color: #f44336; font-size: 0.8rem; margin-top: 0.25rem; display: block; }
    .role-selector { display: flex; gap: 1rem; }
    .role-btn { flex: 1; padding: 0.75rem; border: 2px solid #e0e0e0; border-radius: 8px; background: white; cursor: pointer; font-size: 1rem; transition: all 0.2s; }
    .role-btn:hover { border-color: #1a237e; }
    .role-btn.active { border-color: #1a237e; background: #e8eaf6; color: #1a237e; font-weight: 600; }
    .btn-submit { width: 100%; padding: 0.85rem; background: linear-gradient(135deg, #1a237e, #3949ab); color: white; border: none; border-radius: 8px; font-size: 1.05rem; font-weight: 600; cursor: pointer; }
    .btn-submit:disabled { opacity: 0.5; cursor: not-allowed; }
  `]
})
export class LoginComponent {
  private fb = inject(FormBuilder);
  private authService = inject(AuthService);
  private walletApi = inject(WalletApiService);
  private notification = inject(NotificationService);
  loading = false;

  loginForm = this.fb.group({
    phone: ['', [Validators.required, phoneValidator()]],
    role: ['CLIENT' as 'CLIENT' | 'AGENT', Validators.required]
  });

  setRole(role: 'CLIENT' | 'AGENT'): void { this.loginForm.patchValue({ role }); }

  onSubmit(): void {
    if (this.loginForm.invalid) return;
    const { phone, role } = this.loginForm.value;
    this.loading = true;
    if (role === 'CLIENT') {
      this.walletApi.searchByPhone(phone!).subscribe({
        next: (wallet) => { this.authService.login(phone!, 'CLIENT', wallet.id); this.notification.success('Connexion réussie !'); this.loading = false; },
        error: () => { this.notification.error('Aucun portefeuille trouvé pour ce numéro.'); this.loading = false; }
      });
    } else {
      this.authService.login(phone!, 'AGENT');
      this.notification.success('Connexion agent réussie !');
      this.loading = false;
    }
  }
}
ENDOFFILE

# ===== CLIENT DASHBOARD =====
cat > src/app/features/client/dashboard/dashboard.component.ts << 'ENDOFFILE'
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
ENDOFFILE

# ===== CLIENT TRANSFER =====
cat > src/app/features/client/transfer/transfer.component.ts << 'ENDOFFILE'
import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { AuthService } from '../../../core/services/auth.service';
import { WalletApiService } from '../../../core/services/wallet-api.service';
import { BalanceStore } from '../../../core/services/balance.store';
import { NotificationService } from '../../../core/services/notification.service';
import { XofPipe } from '../../../shared/pipes/xof.pipe';
import { phoneValidator, differentPhoneValidator } from '../../../shared/validators/phone.validator';

@Component({
  selector: 'app-transfer',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, XofPipe],
  template: `
    <div class="transfer-page">
      <h2>💸 Transfert d'argent</h2>
      <div class="transfer-card">
        <form [formGroup]="transferForm" (ngSubmit)="onSubmit()">
          <div class="form-group">
            <label for="destination">Numéro destinataire</label>
            <input id="destination" type="tel" formControlName="destination" placeholder="77 XXX XX XX" [class.error]="isFieldInvalid('destination')" />
            <span class="error-msg" *ngIf="isFieldInvalid('destination') && transferForm.get('destination')?.hasError('required')">Le numéro destinataire est requis</span>
            <span class="error-msg" *ngIf="isFieldInvalid('destination') && transferForm.get('destination')?.hasError('invalidPhone')">Numéro invalide</span>
            <span class="error-msg" *ngIf="transferForm.hasError('samePhone')">Vous ne pouvez pas transférer à votre propre numéro</span>
          </div>
          <div class="form-group">
            <label for="amount">Montant</label>
            <div class="amount-input"><input id="amount" type="number" formControlName="amount" placeholder="0" [class.error]="isFieldInvalid('amount')" /><span class="currency">XOF</span></div>
            <span class="error-msg" *ngIf="isFieldInvalid('amount') && transferForm.get('amount')?.hasError('required')">Le montant est requis</span>
            <span class="error-msg" *ngIf="isFieldInvalid('amount') && transferForm.get('amount')?.hasError('min')">Le montant doit être supérieur à 0</span>
          </div>
          <div class="form-group">
            <label for="description">Description (optionnel)</label>
            <input id="description" type="text" formControlName="description" placeholder="Ex: Remboursement déjeuner" />
          </div>
          <div class="balance-info">Solde disponible : <strong>{{ balanceStore.balance() | xof }}</strong></div>
          <button type="submit" class="btn-transfer" [disabled]="transferForm.invalid || loading">{{ loading ? 'Envoi en cours...' : 'Envoyer' }}</button>
        </form>
      </div>
    </div>
  `,
  styles: [`
    .transfer-page { max-width: 500px; margin: 0 auto; }
    h2 { color: #1a237e; margin-bottom: 1.5rem; }
    .transfer-card { background: white; border-radius: 16px; padding: 2rem; box-shadow: 0 4px 16px rgba(0,0,0,0.08); }
    .form-group { margin-bottom: 1.5rem; }
    label { display: block; margin-bottom: 0.5rem; font-weight: 500; color: #333; }
    input { width: 100%; padding: 0.75rem 1rem; border: 2px solid #e0e0e0; border-radius: 8px; font-size: 1rem; box-sizing: border-box; }
    input:focus { outline: none; border-color: #1a237e; }
    input.error { border-color: #f44336; }
    .error-msg { color: #f44336; font-size: 0.8rem; margin-top: 0.25rem; display: block; }
    .amount-input { position: relative; display: flex; align-items: center; }
    .amount-input input { padding-right: 4rem; }
    .currency { position: absolute; right: 1rem; color: #666; font-weight: 500; }
    .balance-info { background: #e8eaf6; padding: 0.75rem 1rem; border-radius: 8px; margin-bottom: 1.5rem; font-size: 0.9rem; color: #1a237e; }
    .btn-transfer { width: 100%; padding: 0.85rem; background: linear-gradient(135deg, #1a237e, #3949ab); color: white; border: none; border-radius: 8px; font-size: 1.05rem; font-weight: 600; cursor: pointer; }
    .btn-transfer:disabled { opacity: 0.5; cursor: not-allowed; }
  `]
})
export class TransferComponent {
  private fb = inject(FormBuilder);
  private authService = inject(AuthService);
  private walletApi = inject(WalletApiService);
  private notification = inject(NotificationService);
  balanceStore = inject(BalanceStore);
  loading = false;
  private currentPhone = this.authService.getPhone();

  transferForm = this.fb.group({
    destination: ['', [Validators.required, phoneValidator()]],
    amount: [null as number | null, [Validators.required, Validators.min(1)]],
    description: ['']
  }, { validators: differentPhoneValidator(this.currentPhone) });

  isFieldInvalid(field: string): boolean { const c = this.transferForm.get(field); return !!(c?.touched && c?.invalid); }

  onSubmit(): void {
    if (this.transferForm.invalid) return;
    this.loading = true;
    const { destination, amount, description } = this.transferForm.value;
    this.walletApi.transfer({ senderPhone: this.currentPhone, receiverPhone: destination!, amount: amount!, description: description || undefined }).subscribe({
      next: () => { this.notification.success(`Transfert de ${amount} XOF envoyé !`); this.balanceStore.refresh(this.currentPhone); this.transferForm.reset(); this.loading = false; },
      error: () => { this.loading = false; }
    });
  }
}
ENDOFFILE

# ===== CLIENT TRANSACTIONS =====
cat > src/app/features/client/transactions/transactions.component.ts << 'ENDOFFILE'
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
              <td><span class="type-badge" [class]="'type-' + tx.type.toLowerCase()">{{ getTypeLabel(tx.type) }}</span></td>
              <td><span *ngIf="tx.description">{{ tx.description }}</span><span *ngIf="tx.receiverPhone" class="phone-detail">→ {{ tx.receiverPhone | phoneFormat }}</span><span *ngIf="tx.senderPhone && tx.type === 'TRANSFER_RECEIVED'" class="phone-detail">← {{ tx.senderPhone | phoneFormat }}</span></td>
              <td [class.positive]="isPositive(tx)" [class.negative]="!isPositive(tx)">{{ isPositive(tx) ? '+' : '-' }}{{ tx.amount | xof }}</td>
              <td><span class="status-badge" [class]="'status-' + tx.status.toLowerCase()">{{ tx.status }}</span></td>
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
ENDOFFILE

# ===== CLIENT BILLS =====
cat > src/app/features/client/bills/bills.component.ts << 'ENDOFFILE'
import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterOutlet, RouterLink, RouterLinkActive } from '@angular/router';

@Component({
  selector: 'app-bills',
  standalone: true,
  imports: [CommonModule, RouterOutlet, RouterLink, RouterLinkActive],
  template: `
    <div class="bills-page">
      <h2>📄 Espace Factures</h2>
      <nav class="bills-nav">
        <a routerLink="current" routerLinkActive="active">Factures impayées</a>
        <a routerLink="history" routerLinkActive="active">Historique des paiements</a>
      </nav>
      <router-outlet></router-outlet>
    </div>
  `,
  styles: [`
    .bills-page { max-width: 800px; margin: 0 auto; }
    h2 { color: #1a237e; margin-bottom: 1.5rem; }
    .bills-nav { display: flex; gap: 0; margin-bottom: 1.5rem; border-bottom: 2px solid #e0e0e0; }
    .bills-nav a { padding: 0.75rem 1.5rem; text-decoration: none; color: #666; font-weight: 500; border-bottom: 2px solid transparent; margin-bottom: -2px; transition: all 0.2s; }
    .bills-nav a:hover { color: #1a237e; }
    .bills-nav a.active { color: #1a237e; border-bottom-color: #1a237e; }
  `]
})
export class BillsComponent {}
ENDOFFILE

cat > src/app/features/client/bills/current-bills/current-bills.component.ts << 'ENDOFFILE'
import { Component, inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { AuthService } from '../../../../core/services/auth.service';
import { BillingApiService, Facture } from '../../../../core/services/billing-api.service';
import { WalletApiService } from '../../../../core/services/wallet-api.service';
import { BalanceStore } from '../../../../core/services/balance.store';
import { NotificationService } from '../../../../core/services/notification.service';
import { XofPipe } from '../../../../shared/pipes/xof.pipe';
import { LoaderComponent } from '../../../../shared/components/loader/loader.component';

@Component({
  selector: 'app-current-bills',
  standalone: true,
  imports: [CommonModule, FormsModule, XofPipe, LoaderComponent],
  template: `
    <div class="current-bills">
      <div class="filter-bar"><label>Fournisseur :</label><select [(ngModel)]="selectedProvider" (ngModelChange)="loadFactures()"><option value="">Tous</option><option *ngFor="let p of providers" [value]="p">{{ p }}</option></select></div>
      <app-loader [loading]="loading" message="Chargement..."></app-loader>
      <div *ngIf="!loading">
        <div *ngIf="factures.length === 0" class="empty-state">🎉 Aucune facture impayée !</div>
        <div *ngIf="factures.length > 0">
          <div class="select-all"><label><input type="checkbox" [checked]="allSelected" (change)="toggleAll()" /> Tout sélectionner</label><span class="selected-info" *ngIf="selectedIds.size > 0">{{ selectedIds.size }} facture(s) — Total : {{ getSelectedTotal() | xof }}</span></div>
          <div class="factures-list">
            <div *ngFor="let facture of factures" class="facture-item" [class.selected]="selectedIds.has(facture.id)">
              <input type="checkbox" [checked]="selectedIds.has(facture.id)" (change)="toggleFacture(facture.id)" />
              <div class="facture-info"><span class="facture-provider">{{ facture.provider }}</span><span class="facture-ref">Réf: {{ facture.reference }}</span><span class="facture-due">Échéance: {{ facture.dueDate | date:'dd/MM/yyyy' }}</span></div>
              <span class="facture-amount">{{ facture.amount | xof }}</span>
            </div>
          </div>
          <button class="btn-pay" [disabled]="selectedIds.size === 0 || paying" (click)="paySelected()">{{ paying ? 'Paiement en cours...' : 'Payer les factures sélectionnées' }}</button>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .filter-bar { display: flex; align-items: center; gap: 0.75rem; margin-bottom: 1.5rem; }
    .filter-bar label { font-weight: 500; }
    .filter-bar select { padding: 0.5rem 0.75rem; border: 1px solid #ddd; border-radius: 6px; }
    .select-all { display: flex; align-items: center; justify-content: space-between; padding: 0.75rem 1rem; background: #f5f5f5; border-radius: 8px; margin-bottom: 1rem; }
    .select-all label { display: flex; align-items: center; gap: 0.5rem; cursor: pointer; font-weight: 500; }
    .selected-info { font-size: 0.85rem; color: #1a237e; font-weight: 500; }
    .factures-list { display: flex; flex-direction: column; gap: 0.75rem; }
    .facture-item { display: flex; align-items: center; gap: 1rem; padding: 1rem; background: white; border: 2px solid #e0e0e0; border-radius: 10px; transition: all 0.2s; }
    .facture-item.selected { border-color: #1a237e; background: #e8eaf6; }
    .facture-info { flex: 1; display: flex; flex-direction: column; gap: 0.25rem; }
    .facture-provider { font-weight: 600; }
    .facture-ref { font-size: 0.85rem; color: #666; }
    .facture-due { font-size: 0.8rem; color: #999; }
    .facture-amount { font-weight: 700; font-size: 1.1rem; color: #1a237e; }
    .btn-pay { width: 100%; margin-top: 1.5rem; padding: 0.85rem; background: linear-gradient(135deg, #4caf50, #66bb6a); color: white; border: none; border-radius: 8px; font-size: 1.05rem; font-weight: 600; cursor: pointer; }
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
  factures: Facture[] = []; providers: string[] = []; selectedProvider = ''; selectedIds = new Set<number>(); loading = true; paying = false;
  get allSelected(): boolean { return this.factures.length > 0 && this.selectedIds.size === this.factures.length; }

  ngOnInit(): void {
    this.billingApi.getProviders().subscribe({ next: (p) => this.providers = p, error: () => { this.providers = ['WOYAFAL', 'ISM', 'SENELEC', 'SDE']; } });
    this.loadFactures();
  }

  loadFactures(): void {
    this.loading = true; this.selectedIds.clear();
    this.billingApi.getUnpaidFactures(this.authService.getPhone(), this.selectedProvider || undefined).subscribe({
      next: (f) => { this.factures = f; this.loading = false; },
      error: () => { this.loading = false; }
    });
  }

  toggleFacture(id: number): void { this.selectedIds.has(id) ? this.selectedIds.delete(id) : this.selectedIds.add(id); }
  toggleAll(): void { this.allSelected ? this.selectedIds.clear() : this.factures.forEach(f => this.selectedIds.add(f.id)); }
  getSelectedTotal(): number { return this.factures.filter(f => this.selectedIds.has(f.id)).reduce((s, f) => s + f.amount, 0); }

  paySelected(): void {
    this.paying = true; const phone = this.authService.getPhone();
    this.walletApi.payFactures({ walletPhone: phone, factureIds: Array.from(this.selectedIds) }).subscribe({
      next: () => { this.notification.success(`${this.selectedIds.size} facture(s) payée(s) !`); this.balanceStore.refresh(phone); this.loadFactures(); this.paying = false; },
      error: () => { this.paying = false; }
    });
  }
}
ENDOFFILE

cat > src/app/features/client/bills/bills-history/bills-history.component.ts << 'ENDOFFILE'
import { Component, inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { AuthService } from '../../../../core/services/auth.service';
import { BillingApiService, Facture } from '../../../../core/services/billing-api.service';
import { XofPipe } from '../../../../shared/pipes/xof.pipe';
import { LoaderComponent } from '../../../../shared/components/loader/loader.component';

@Component({
  selector: 'app-bills-history',
  standalone: true,
  imports: [CommonModule, XofPipe, LoaderComponent],
  template: `
    <div class="bills-history">
      <app-loader [loading]="loading" message="Chargement..."></app-loader>
      <div *ngIf="!loading">
        <div *ngIf="factures.length === 0" class="empty-state">Aucun historique de paiement</div>
        <table *ngIf="factures.length > 0">
          <thead><tr><th>Date</th><th>Fournisseur</th><th>Référence</th><th>Montant</th><th>Statut</th></tr></thead>
          <tbody><tr *ngFor="let f of factures"><td>{{ f.dueDate | date:'dd/MM/yyyy' }}</td><td>{{ f.provider }}</td><td>{{ f.reference }}</td><td>{{ f.amount | xof }}</td><td><span class="status-paid">✅ Payée</span></td></tr></tbody>
        </table>
      </div>
    </div>
  `,
  styles: [`table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; } th { background: #f5f5f5; padding: 0.75rem 1rem; text-align: left; font-size: 0.85rem; color: #666; } td { padding: 0.75rem 1rem; border-bottom: 1px solid #f0f0f0; } .status-paid { color: #4caf50; font-weight: 500; } .empty-state { text-align: center; padding: 2rem; color: #999; }`]
})
export class BillsHistoryComponent implements OnInit {
  private authService = inject(AuthService);
  private billingApi = inject(BillingApiService);
  factures: Facture[] = []; loading = true;

  ngOnInit(): void {
    this.billingApi.getFactureHistory(this.authService.getPhone()).subscribe({
      next: (data) => { this.factures = data; this.loading = false; },
      error: () => { this.loading = false; }
    });
  }
}
ENDOFFILE

# ===== AGENT WALLET LIST =====
cat > src/app/features/agent/wallet-list/wallet-list.component.ts << 'ENDOFFILE'
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
ENDOFFILE

# ===== AGENT WALLET CREATE =====
cat > src/app/features/agent/wallet-create/wallet-create.component.ts << 'ENDOFFILE'
import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { WalletApiService } from '../../../core/services/wallet-api.service';
import { NotificationService } from '../../../core/services/notification.service';
import { phoneValidator } from '../../../shared/validators/phone.validator';

@Component({
  selector: 'app-wallet-create',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  template: `
    <div class="create-page">
      <h2>➕ Créer un portefeuille</h2>
      <div class="form-card">
        <form [formGroup]="createForm" (ngSubmit)="onSubmit()">
          <div class="form-group"><label>Prénom</label><input type="text" formControlName="firstName" placeholder="Prénom" [class.error]="isFieldInvalid('firstName')" /><span class="error-msg" *ngIf="isFieldInvalid('firstName')">Le prénom est requis</span></div>
          <div class="form-group"><label>Nom</label><input type="text" formControlName="lastName" placeholder="Nom" [class.error]="isFieldInvalid('lastName')" /><span class="error-msg" *ngIf="isFieldInvalid('lastName')">Le nom est requis</span></div>
          <div class="form-group"><label>Téléphone</label><input type="tel" formControlName="phone" placeholder="77 123 45 67" [class.error]="isFieldInvalid('phone')" /><span class="error-msg" *ngIf="isFieldInvalid('phone') && createForm.get('phone')?.hasError('required')">Le numéro est requis</span><span class="error-msg" *ngIf="isFieldInvalid('phone') && createForm.get('phone')?.hasError('invalidPhone')">Numéro invalide</span></div>
          <div class="form-group"><label>Code PIN (optionnel)</label><input type="password" formControlName="pin" placeholder="4 chiffres" maxlength="4" /></div>
          <button type="submit" class="btn-create" [disabled]="createForm.invalid || loading">{{ loading ? 'Création...' : 'Créer le portefeuille' }}</button>
        </form>
        <div class="success-card" *ngIf="createdWallet">
          <h3>✅ Portefeuille créé !</h3>
          <p><strong>ID :</strong> {{ createdWallet.id }}</p>
          <p><strong>Client :</strong> {{ createdWallet.firstName }} {{ createdWallet.lastName }}</p>
          <p><strong>Téléphone :</strong> {{ createdWallet.phone }}</p>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .create-page { max-width: 500px; margin: 0 auto; }
    h2 { color: #1a237e; margin-bottom: 1.5rem; }
    .form-card { background: white; border-radius: 16px; padding: 2rem; box-shadow: 0 4px 16px rgba(0,0,0,0.08); }
    .form-group { margin-bottom: 1.5rem; }
    label { display: block; margin-bottom: 0.5rem; font-weight: 500; }
    input { width: 100%; padding: 0.75rem 1rem; border: 2px solid #e0e0e0; border-radius: 8px; font-size: 1rem; box-sizing: border-box; }
    input:focus { outline: none; border-color: #1a237e; }
    input.error { border-color: #f44336; }
    .error-msg { color: #f44336; font-size: 0.8rem; margin-top: 0.25rem; display: block; }
    .btn-create { width: 100%; padding: 0.85rem; background: linear-gradient(135deg, #1a237e, #3949ab); color: white; border: none; border-radius: 8px; font-size: 1.05rem; font-weight: 600; cursor: pointer; }
    .btn-create:disabled { opacity: 0.5; cursor: not-allowed; }
    .success-card { margin-top: 1.5rem; padding: 1.5rem; background: #e8f5e9; border-radius: 10px; border: 1px solid #a5d6a7; }
    .success-card h3 { color: #2e7d32; margin-bottom: 0.75rem; }
    .success-card p { margin: 0.25rem 0; }
  `]
})
export class WalletCreateComponent {
  private fb = inject(FormBuilder);
  private walletApi = inject(WalletApiService);
  private notification = inject(NotificationService);
  loading = false; createdWallet: any = null;

  createForm = this.fb.group({
    firstName: ['', Validators.required],
    lastName: ['', Validators.required],
    phone: ['', [Validators.required, phoneValidator()]],
    pin: ['']
  });

  isFieldInvalid(field: string): boolean { const c = this.createForm.get(field); return !!(c?.touched && c?.invalid); }

  onSubmit(): void {
    if (this.createForm.invalid) return;
    this.loading = true; this.createdWallet = null;
    const { firstName, lastName, phone, pin } = this.createForm.value;
    this.walletApi.createWallet({ firstName: firstName!, lastName: lastName!, phone: phone!, pin: pin || undefined }).subscribe({
      next: (wallet) => { this.createdWallet = wallet; this.notification.success('Portefeuille créé !'); this.createForm.reset(); this.loading = false; },
      error: () => { this.loading = false; }
    });
  }
}
ENDOFFILE

# ===== AGENT WALLET SEARCH =====
cat > src/app/features/agent/wallet-search/wallet-search.component.ts << 'ENDOFFILE'
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
ENDOFFILE

# ===== AGENT DEPOSIT/WITHDRAW =====
cat > src/app/features/agent/deposit-withdraw/deposit-withdraw.component.ts << 'ENDOFFILE'
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
          <div class="form-group"><label>Montant</label><div class="amount-input"><input type="number" formControlName="amount" placeholder="0" /><span class="currency">XOF</span></div></div>
          <div class="form-group"><label>Description (optionnel)</label><input type="text" formControlName="description" placeholder="Motif" /></div>
          <button type="submit" class="btn-action deposit" [disabled]="depositForm.invalid || !depositClient || loadingDeposit">{{ loadingDeposit ? 'Traitement...' : 'Effectuer le dépôt' }}</button>
        </form>
      </div>
      <div class="form-card" *ngIf="activeTab === 'withdraw'">
        <form [formGroup]="withdrawForm" (ngSubmit)="onWithdraw()">
          <div class="form-group"><label>Téléphone client</label><div class="search-inline"><input type="tel" formControlName="phone" placeholder="77 123 45 67" /><button type="button" (click)="searchForWithdraw()" [disabled]="!withdrawForm.get('phone')?.valid">🔍</button></div></div>
          <div class="client-info" *ngIf="withdrawClient"><span>👤 {{ withdrawClient.firstName }} {{ withdrawClient.lastName }}</span><span>Solde : {{ withdrawClient.balance | xof }}</span></div>
          <div class="form-group"><label>Montant</label><div class="amount-input"><input type="number" formControlName="amount" placeholder="0" /><span class="currency">XOF</span></div></div>
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
    .tab-btn { flex: 1; padding: 0.75rem; border: 2px solid #e0e0e0; border-radius: 8px; background: white; font-size: 1rem; font-weight: 500; cursor: pointer; transition: all 0.2s; }
    .tab-btn.active { border-color: #1a237e; background: #e8eaf6; color: #1a237e; }
    .form-card { background: white; border-radius: 16px; padding: 2rem; box-shadow: 0 4px 16px rgba(0,0,0,0.08); }
    .form-group { margin-bottom: 1.5rem; }
    label { display: block; margin-bottom: 0.5rem; font-weight: 500; }
    input { width: 100%; padding: 0.75rem 1rem; border: 2px solid #e0e0e0; border-radius: 8px; font-size: 1rem; box-sizing: border-box; }
    input:focus { outline: none; border-color: #1a237e; }
    .search-inline { display: flex; gap: 0.5rem; }
    .search-inline input { flex: 1; }
    .search-inline button { padding: 0.75rem 1rem; background: #1a237e; color: white; border: none; border-radius: 8px; cursor: pointer; }
    .search-inline button:disabled { opacity: 0.5; }
    .client-info { display: flex; justify-content: space-between; padding: 0.75rem 1rem; background: #e8f5e9; border-radius: 8px; margin-bottom: 1.5rem; font-size: 0.9rem; color: #2e7d32; }
    .amount-input { position: relative; }
    .amount-input input { padding-right: 4rem; }
    .currency { position: absolute; right: 1rem; top: 50%; transform: translateY(-50%); color: #666; }
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

  depositForm = this.fb.group({ phone: ['', [Validators.required, phoneValidator()]], amount: [null as number | null, [Validators.required, Validators.min(1)]], description: [''] });
  withdrawForm = this.fb.group({ phone: ['', [Validators.required, phoneValidator()]], amount: [null as number | null, [Validators.required, Validators.min(1)]], description: [''] });

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
    const { amount, description } = this.depositForm.value;
    this.walletApi.deposit(this.depositClient.id, { amount: amount!, description: description || undefined }).subscribe({
      next: () => { this.notification.success(`Dépôt de ${amount} XOF effectué !`); this.depositForm.reset(); this.depositClient = null; this.loadingDeposit = false; },
      error: () => { this.loadingDeposit = false; }
    });
  }

  onWithdraw(): void {
    if (this.withdrawForm.invalid || !this.withdrawClient) return;
    this.loadingWithdraw = true;
    const { phone, amount, description } = this.withdrawForm.value;
    this.walletApi.withdraw({ walletId: this.withdrawClient.id, phone: phone!, amount: amount!, description: description || undefined }).subscribe({
      next: () => { this.notification.success(`Retrait de ${amount} XOF effectué !`); this.withdrawForm.reset(); this.withdrawClient = null; this.loadingWithdraw = false; },
      error: () => { this.loadingWithdraw = false; }
    });
  }
}
ENDOFFILE

# ===== styles.scss =====
cat > src/styles.scss << 'ENDOFFILE'
* { margin: 0; padding: 0; box-sizing: border-box; }
body { font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #f5f7fa; color: #333; line-height: 1.6; }
::-webkit-scrollbar { width: 8px; }
::-webkit-scrollbar-track { background: #f0f0f0; }
::-webkit-scrollbar-thumb { background: #bbb; border-radius: 4px; }
@media (max-width: 768px) {
  .main-content { padding: 1rem !important; }
  .header { flex-direction: column; gap: 0.5rem; padding: 0.75rem 1rem !important; }
  .nav-links a { margin: 0 0.25rem !important; padding: 0.4rem 0.5rem !important; font-size: 0.85rem; }
}
ENDOFFILE

# ===== index.html =====
cat > src/index.html << 'ENDOFFILE'
<!doctype html>
<html lang="fr">
<head>
  <meta charset="utf-8">
  <title>BadWallet - Dashboard</title>
  <base href="/">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="icon" type="image/x-icon" href="favicon.ico">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
</head>
<body>
  <app-root></app-root>
</body>
</html>
ENDOFFILE

# ===== main.ts =====
cat > src/main.ts << 'ENDOFFILE'
import { bootstrapApplication } from '@angular/platform-browser';
import { appConfig } from './app/app.config';
import { AppComponent } from './app/app.component';

bootstrapApplication(AppComponent, appConfig).catch((err) => console.error(err));
ENDOFFILE

echo ""
echo "✅ Projet BadWallet généré avec succès !"
echo ""
echo "📋 Prochaines étapes :"
echo "   1. ng new badwallet --standalone --routing --style=scss"
echo "   2. cd badwallet"
echo "   3. Copiez ce script ici et lancez: bash setup.sh"
echo "   4. ng serve"
echo ""