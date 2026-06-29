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
