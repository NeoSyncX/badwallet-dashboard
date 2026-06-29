import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';

export interface Wallet { id: number; phone: string; firstName: string; lastName: string; balance: number; createdAt?: string; }
export interface WalletPage { content: Wallet[]; totalElements: number; totalPages: number; number: number; size: number; }
export interface CreateWalletDto { phone: string; firstName: string; lastName: string; pin?: string; }
export interface TransferDto { senderPhone: string; receiverPhone: string; amount: number; description?: string; }
export interface DepositDto { amount: number; paymentMethod: string; description?: string; }
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
  getBalance(phone: string): Observable<any> { return this.http.get<any>(`${this.BASE}/${phone}/balance`); }
  transfer(dto: TransferDto): Observable<any> { return this.http.post(`${this.BASE}/transfer`, dto); }
  getTransactions(phone: string): Observable<Transaction[]> { return this.http.get<Transaction[]>(`${this.BASE}/${phone}/transactions`); }
  payFactures(payload: { walletPhone: string; factureIds: number[] }): Observable<any> { return this.http.post(`${this.BASE}/pay-factures`, payload); }
}
