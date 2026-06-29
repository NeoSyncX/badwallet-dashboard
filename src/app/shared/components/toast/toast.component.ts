import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { NotificationService, Toast } from '../../../core/services/notification.service';

@Component({
  selector: 'app-toast',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="toast-container">
      <div *ngFor="let toast of notificationService.toasts(); trackBy: trackById" class="toast" [class]="'toast-' + toast.type" (click)="dismiss(toast)">
        <span class="toast-icon">
          <ng-container [ngSwitch]="toast.type">
            <span *ngSwitchCase="'success'">✅</span>
            <span *ngSwitchCase="'error'">❌</span>
            <span *ngSwitchCase="'warning'">⚠️</span>
            <span *ngSwitchCase="'info'">ℹ️</span>
          </ng-container>
        </span>
        <span class="toast-message">{{ toast.message }}</span>
        <button class="toast-close" (click)="dismiss(toast)">×</button>
      </div>
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
  trackById(index: number, toast: Toast): number { return toast.id; }
}
