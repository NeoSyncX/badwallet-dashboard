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
