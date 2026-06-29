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
