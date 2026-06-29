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
